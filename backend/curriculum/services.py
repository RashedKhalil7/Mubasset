import re
from pathlib import Path

from django.db import transaction

from .models import CurriculumChunk, CurriculumDocument

WORD_RE = re.compile(r"[\w\u0600-\u06FF]+", re.UNICODE)
CHUNK_SIZE = 1800
CHUNK_OVERLAP = 250


def _terms(text):
    return " ".join(dict.fromkeys(WORD_RE.findall(text.lower())))


def _split(text):
    text = re.sub(r"\s+", " ", text).strip()
    start = 0
    while start < len(text):
        end = min(start + CHUNK_SIZE, len(text))
        if end < len(text):
            boundary = text.rfind(" ", start, end)
            if boundary > start + 500:
                end = boundary
        chunk = text[start:end].strip()
        if chunk:
            yield chunk
        if end >= len(text):
            break
        start = max(end - CHUNK_OVERLAP, start + 1)


def _extract_pages(document):
    suffix = Path(document.file.name).suffix.lower()
    if suffix == ".pdf":
        try:
            from pypdf import PdfReader
        except ImportError as exc:
            raise RuntimeError("Install pypdf to process PDF curriculum books.") from exc
        return [
            (number, page.extract_text() or "")
            for number, page in enumerate(PdfReader(document.file.path).pages, 1)
        ]
    if suffix in {".txt", ".md"}:
        return [(None, document.file.read().decode("utf-8"))]
    raise ValueError("Only PDF, TXT, and Markdown curriculum files are supported.")


@transaction.atomic
def process_document(document):
    document.chunks.all().delete()
    chunks = []
    for page_number, text in _extract_pages(document):
        for content in _split(text):
            chunks.append(
                CurriculumChunk(
                    document=document,
                    page_number=page_number,
                    content=content,
                    search_terms=_terms(content),
                )
            )
    if not chunks:
        raise ValueError("The book contains no extractable text.")
    CurriculumChunk.objects.bulk_create(chunks)
    document.processed = True
    document.processing_error = ""
    document.save(update_fields=["processed", "processing_error"])


def retrieve_chunks(question, limit=5):
    terms = set(WORD_RE.findall(question.lower()))
    if not terms:
        return []
    candidates = CurriculumChunk.objects.filter(document__processed=True)
    ranked = []
    for chunk in candidates.iterator():
        chunk_terms = set(chunk.search_terms.split())
        score = len(terms & chunk_terms)
        if score:
            ranked.append((score, chunk))
    ranked.sort(key=lambda item: item[0], reverse=True)
    return [chunk for _, chunk in ranked[:limit]]
