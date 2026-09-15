import json
import logging
import urllib.error
import urllib.request

from django.conf import settings
from rest_framework import permissions, status
from rest_framework.parsers import JSONParser, MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import CurriculumDocument
from .services import process_document, retrieve_chunks

logger = logging.getLogger(__name__)


class CurriculumUploadView(APIView):
    permission_classes = [permissions.IsAdminUser]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        uploaded_file = request.FILES.get("file")
        if uploaded_file is None:
            return Response({"detail": "file is required"}, status=400)
        document = CurriculumDocument.objects.create(
            title=request.data.get("title", uploaded_file.name),
            subject=request.data.get("subject", "غير محدد"),
            grade=request.data.get("grade", "الثالث الثانوي"),
            file=uploaded_file,
        )
        try:
            process_document(document)
        except (OSError, ValueError, RuntimeError) as exc:
            document.processing_error = str(exc)
            document.save(update_fields=["processing_error"])
            return Response({"detail": str(exc)}, status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        return Response(
            {"id": document.id, "title": document.title, "chunks": document.chunks.count()},
            status=status.HTTP_201_CREATED,
        )


class CurriculumChatView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [JSONParser]

    def post(self, request):
        question = str(request.data.get("message", "")).strip()
        history = request.data.get("history", [])
        if not question:
            return Response({"detail": "message is required"}, status=400)
        if not isinstance(history, list):
            return Response({"detail": "history must be a list"}, status=400)

        chunks = retrieve_chunks(question)
        context = "\n\n".join(
            f"[{chunk.document.subject} - {chunk.document.title}, "
            f"صفحة {chunk.page_number or '?'}]\n{chunk.content}"
            for chunk in chunks
        )
        try:
            answer = _generate_answer(question, history[-8:], context)
        except RuntimeError as exc:
            return Response({"detail": str(exc)}, status=503)
        return Response(
            {
                "answer": answer,
                "sources": [
                    {
                        "title": chunk.document.title,
                        "subject": chunk.document.subject,
                        "page": chunk.page_number,
                    }
                    for chunk in chunks
                ],
            }
        )


def _generate_answer(question, history, context):
    api_key = getattr(settings, "GEMINI_API_KEY", "")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY is not configured on the server.")
    prompt = (
        "أنت مساعد تعليمي ذكي لطلاب الصف الثالث الثانوي في السودان. "
        "أجب بالعربية الفصحى الواضحة ما لم يطلب الطالب غير ذلك. "
        "اعتمد على سياق الكتب أدناه، وصرّح بوضوح إذا لم تجد الإجابة فيه. "
        "اشرح خطوة بخطوة، ولا تكتف بالإجابة النهائية في التمارين. "
        "لا تخترع قوانين أو معلومات غير موجودة في السياق.\n\n"
        f"سياق الكتب:\n{context or 'لا يوجد مقطع مطابق؛ أجب بحذر واطلب اسم المادة أو الدرس.'}\n\n"
        f"سجل المحادثة:\n{json.dumps(history, ensure_ascii=False)}\n\n"
        f"سؤال الطالب:\n{question}"
    )
    body = json.dumps(
        {
            "contents": [{"role": "user", "parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.25, "maxOutputTokens": 2048},
        },
        ensure_ascii=False,
    ).encode()
    model = getattr(settings, "GEMINI_MODEL", "gemini-2.5-flash")
    request = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
        data=body,
        headers={"Content-Type": "application/json", "x-goog-api-key": api_key},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=45) as response:
            data = json.loads(response.read())
    except urllib.error.URLError as exc:
        logger.exception("Gemini request failed")
        raise RuntimeError("The AI service is temporarily unavailable.") from exc
    parts = data.get("candidates", [{}])[0].get("content", {}).get("parts", [])
    answer = "\n".join(part.get("text", "") for part in parts).strip()
    if not answer:
        raise RuntimeError("The AI service returned an empty response.")
    return answer
