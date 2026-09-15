from django.conf import settings
from django.db import models


class Book(models.Model):
    title = models.CharField(max_length=255)
    subject = models.CharField(max_length=100)
    grade = models.CharField(max_length=100, default="الثالث الثانوي")
    language = models.CharField(max_length=20, default="ar")
    source_filename = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["subject", "title"]

    def __str__(self):
        return f"{self.subject}: {self.title}"


class BookChunk(models.Model):
    book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name="chunks")
    page_number = models.PositiveIntegerField(null=True, blank=True)
    content = models.TextField()
    search_text = models.TextField(editable=False)

    class Meta:
        ordering = ["book", "page_number", "id"]


class ChatMessage(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    role = models.CharField(max_length=10, choices=[("user", "User"), ("model", "Model")])
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["created_at", "id"]
