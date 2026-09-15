import re
from pathlib import Path

from django.core.management.base import BaseCommand, CommandError

from learning.models import Book, BookChunk
from learning.services import normalize_arabic


class Command(BaseCommand):
    help = "Import PDF/text curriculum books from a directory into searchable chunks."

    def add_arguments(self, parser):
        parser.add_argument("directory", type=Path)
        parser.add_argument("--subject", required=True)
        parser.add_argument("--chunk-words", type=int, default=180)

    def handle(self, *args, **options):
        directory = options["directory"]
        if not directory.is_dir():
            raise CommandError(f"Directory does not exist: {directory}")

        try:
            from pypdf import PdfReader
        except ImportError as exc:
            raise CommandError("Install pypdf with: pip install pypdf") from exc

        files = sorted(path for path in directory.iterdir() if path.suffix.lower() == ".pdf")
        if not files:
            raise CommandError("No PDF files found in the directory.")

        total = 0
        for path in files:
            book, _ = Book.objects.update_or_create(
                source_filename=path.name,
                defaults={"title": path.stem, "subject": options["subject"]},
            )
            book.chunks.all().delete()
            for page_number, page in enumerate(PdfReader(str(path)).pages, start=1):
                text = re.sub(r"\s+", " ", page.extract_text() or "").strip()
                words = text.split()
                size = options["chunk_words"]
                for start in range(0, len(words), size):
                    content = " ".join(words[start : start + size]).strip()
                    if content:
                        BookChunk.objects.create(
                            book=book,
                            page_number=page_number,
                            content=content,
                            search_text=normalize_arabic(content),
                        )
                        total += 1
        self.stdout.write(self.style.SUCCESS(f"Imported {len(files)} books and {total} chunks."))
