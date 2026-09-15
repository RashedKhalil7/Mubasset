from pathlib import Path

from django.core.management.base import BaseCommand, CommandError
from django.core.files import File

from curriculum.models import CurriculumDocument
from curriculum.services import process_document


class Command(BaseCommand):
    help = "Import a Sudanese third-year curriculum book from a local PDF/TXT/MD file."

    def add_arguments(self, parser):
        parser.add_argument("path", type=Path)
        parser.add_argument("--title", required=True)
        parser.add_argument("--subject", required=True)
        parser.add_argument("--grade", default="الثالث الثانوي")

    def handle(self, *args, **options):
        path = options["path"]
        if not path.is_file():
            raise CommandError(f"File not found: {path}")
        document = CurriculumDocument(
            title=options["title"],
            subject=options["subject"],
            grade=options["grade"],
        )
        with path.open("rb") as book:
            document.file.save(path.name, File(book), save=True)
        try:
            process_document(document)
        except (OSError, ValueError, RuntimeError) as exc:
            document.delete()
            raise CommandError(str(exc)) from exc
        self.stdout.write(
            self.style.SUCCESS(
                f"Imported {document.title} ({document.chunks.count()} chunks)."
            )
        )
