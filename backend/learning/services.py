import re
import unicodedata

from django.db.models import Q

from .models import BookChunk


def normalize_arabic(value):
    value = unicodedata.normalize("NFKC", value).lower()
    value = re.sub(r"[\u064B-\u065F\u0670]", "", value)
    value = value.replace("أ", "ا").replace("إ", "ا").replace("آ", "ا")
    value = value.replace("ة", "ه").replace("ى", "ي")
    return re.sub(r"\s+", " ", value).strip()


def find_relevant_chunks(question, limit=6):
    terms = [term for term in normalize_arabic(question).split() if len(term) > 2]
    if not terms:
        return []

    query = Q()
    for term in terms:
        query |= Q(search_text__icontains=term)

    candidates = list(BookChunk.objects.filter(query).select_related("book")[:80])
    scored = sorted(
        candidates,
        key=lambda chunk: sum(
            normalize_arabic(chunk.content).count(term) for term in terms
        ),
        reverse=True,
    )
    return scored[:limit]
