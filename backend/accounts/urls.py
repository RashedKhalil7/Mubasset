from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import CheckIdentifierView, LoginView, MeView, RegisterView, SendOTPView, VerifyOTPView

urlpatterns = [
    path("check-identifier/", CheckIdentifierView.as_view(), name="check-identifier"),
    path("send-otp/", SendOTPView.as_view(), name="send-otp"),
    path("verify-otp/", VerifyOTPView.as_view(), name="verify-otp"),
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", LoginView.as_view(), name="login"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("me/", MeView.as_view(), name="me"),
]
