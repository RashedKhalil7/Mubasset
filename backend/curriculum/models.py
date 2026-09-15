from django.db import models


class CurriculumDocument(models.Model):
    title = models.CharField(max_length=255)
    subject = models.CharField(max_length=120)
    grade = models.CharField(max_length=80, default="الثالث الثانوي")
    language = models.CharField(max_length=20, default="ar")
    file = models.FileField(upload_to="curriculum/books/")
    processed = models.BooleanField(default=False)
    processing_error = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["subject", "title"]

    def __str__(self):
        return f"{self.subject}: {self.title}"


class CurriculumChunk(models.Model):
    document = models.ForeignKey(
        CurriculumDocument, on_delete=models.CASCADE, related_name="chunks"
    )
    page_number = models.PositiveIntegerField(null=True, blank=True)
    content = models.TextField()
    search_terms = models.TextField()

    class Meta:
        indexes = [models.Index(fields=["document", "page_number"])]

