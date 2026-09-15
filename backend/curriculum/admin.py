from django.contrib import admin

from .models import CurriculumChunk, CurriculumDocument


@admin.register(CurriculumDocument)
class CurriculumDocumentAdmin(admin.ModelAdmin):
    list_display = ("title", "subject", "grade", "processed", "created_at")
    list_filter = ("subject", "grade", "processed")
    search_fields = ("title", "subject")


@admin.register(CurriculumChunk)
class CurriculumChunkAdmin(admin.ModelAdmin):
    list_display = ("document", "page_number")
    search_fields = ("content", "search_terms")
