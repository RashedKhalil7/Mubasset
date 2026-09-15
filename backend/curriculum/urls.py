from django.urls import path

from .views import CurriculumChatView, CurriculumUploadView

urlpatterns = [
    path("chat/", CurriculumChatView.as_view(), name="curriculum-chat"),
    path("upload/", CurriculumUploadView.as_view(), name="curriculum-upload"),
]
