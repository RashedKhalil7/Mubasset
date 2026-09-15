from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True
    dependencies = []
    operations = [
        migrations.CreateModel(
            name="CurriculumDocument",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("title", models.CharField(max_length=255)),
                ("subject", models.CharField(max_length=120)),
                ("grade", models.CharField(default="الثالث الثانوي", max_length=80)),
                ("language", models.CharField(default="ar", max_length=20)),
                ("file", models.FileField(upload_to="curriculum/books/")),
                ("processed", models.BooleanField(default=False)),
                ("processing_error", models.TextField(blank=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
            ],
            options={"ordering": ["subject", "title"]},
        ),
        migrations.CreateModel(
            name="CurriculumChunk",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("page_number", models.PositiveIntegerField(blank=True, null=True)),
                ("content", models.TextField()),
                ("search_terms", models.TextField()),
                ("document", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="chunks", to="curriculum.curriculumdocument")),
            ],
        ),
        migrations.AddIndex(
            model_name="curriculumchunk",
            index=models.Index(fields=["document", "page_number"], name="curriculum__documen_07af10_idx"),
        ),
    ]
