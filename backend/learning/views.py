import os

import requests
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import ChatMessage
from .services import find_relevant_chunks


ARABIC_TUTOR_PROMPT = """
أنت مساعد تعليمي اسمه مُبَسِّط لطلاب الشهادة السودانية (الثالث الثانوي).
أجب بالعربية عندما يكون سؤال الطالب بالعربية، ويمكنك استخدام المصطلحات الإنجليزية
بين قوسين عند الحاجة. اشرح خطوة بخطوة وبأسلوب واضح يناسب طالب المرحلة الثانوية.
عند حل تمرين، اذكر القانون أو الفكرة ثم الحل والتحقق من الإجابة. لا تخترع معلومة
أو إجابة غير موجودة في السياق. إذا لم تجد الإجابة في الكتب، قل بوضوح إنك غير
متأكد واطلب اسم المادة أو رقم الصفحة. لا تستبدل شرح المعلم أو المنهج الرسمي.
"""


class ChatView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        question = str(request.data.get("message", "")).strip()
        if not question:
            return Response({"message": "اكتب سؤالك أولاً."}, status=status.HTTP_400_BAD_REQUEST)

        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            return Response(
                {"message": "خدمة الذكاء الاصطناعي غير مهيأة على الخادم."},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        chunks = find_relevant_chunks(question)
        context = "\n\n".join(
            f"[{chunk.book.subject} - {chunk.book.title}, الصفحة {chunk.page_number or '?'}]\n"
            f"{chunk.content}"
            for chunk in chunks
        )
        recent = []
        if request.user.is_authenticated:
            recent = list(
                ChatMessage.objects.filter(user=request.user).order_by("-created_at")[:10]
            )
        recent.reverse()
        contents = [
            {"role": message.role, "parts": [{"text": message.content}]}
            for message in recent
        ]
        contents.append(
            {
                "role": "user",
                "parts": [
                    {
                        "text": (
                            f"سياق الكتب المتاح:\n{context or 'لا يوجد سياق مطابق.'}\n\n"
                            f"سؤال الطالب:\n{question}"
                        )
                    }
                ],
            }
        )

        try:
            response = requests.post(
                "https://generativelanguage.googleapis.com/v1beta/models/"
                f"{os.environ.get('GEMINI_MODEL', 'gemini-2.5-flash')}:generateContent",
                params={"key": api_key},
                json={
                    "systemInstruction": {"parts": [{"text": ARABIC_TUTOR_PROMPT}]},
                    "generationConfig": {"temperature": 0.25, "maxOutputTokens": 2048},
                    "contents": contents,
                },
                timeout=45,
            )
        except requests.RequestException:
            return Response(
                {"message": "تعذر الاتصال بخدمة الذكاء الاصطناعي."},
                status=status.HTTP_502_BAD_GATEWAY,
            )
        if response.status_code != 200:
            return Response(
                {"message": "تعذر الحصول على إجابة الآن. حاول مرة أخرى."},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        payload = response.json()
        parts = payload.get("candidates", [{}])[0].get("content", {}).get("parts", [])
        answer = "\n".join(part.get("text", "") for part in parts).strip()
        if not answer:
            return Response({"message": "عاد النموذج بإجابة فارغة."}, status=502)

        if request.user.is_authenticated:
            ChatMessage.objects.create(user=request.user, role="user", content=question)
            ChatMessage.objects.create(user=request.user, role="model", content=answer)
        return Response(
            {
                "answer": answer,
                "sources": [
                    {
                        "book": chunk.book.title,
                        "subject": chunk.book.subject,
                        "page": chunk.page_number,
                    }
                    for chunk in chunks
                ],
            }
        )
