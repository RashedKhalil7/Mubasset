from django.contrib.auth import get_user_model
from django.core import signing
from django.utils import timezone
from rest_framework import parsers, permissions, status
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import OTP
from .serializers import (
    CheckIdentifierSerializer,
    LoginSerializer,
    RegisterSerializer,
    SendOTPSerializer,
    UserSerializer,
    VerifyOTPSerializer,
)
from .utils import create_otp, issue_registration_token, parse_identifier, read_registration_token, send_otp

User = get_user_model()


def tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {"access": str(refresh.access_token), "refresh": str(refresh)}


class CheckIdentifierView(APIView):
    """
    POST /api/auth/check-identifier/  {"identifier": "..."}

    `identifier` is whatever the user typed into login.dart's single
    "email or phone number" field. Used to decide whether to route to
    PasswordLogin (existing user) or OTPRegister (new user).
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = CheckIdentifierSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            identifier, channel = parse_identifier(serializer.validated_data["identifier"])
        except ValueError as e:
            return Response({"identifier": [str(e)]}, status=400)

        exists = User.objects.find_by_identifier(identifier, channel) is not None
        return Response({"exists": exists, "channel": channel})


class SendOTPView(APIView):
    """
    POST /api/auth/send-otp/  {"identifier": "...", "purpose": "register"|"login"}

    Delivers by email or SMS depending on what `identifier` looks like.
    Used by OTPRegister.dart and OTPLogain.dart (on entry / resend).
    """

    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "otp_send"

    def post(self, request):
        serializer = SendOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        purpose = serializer.validated_data["purpose"]

        try:
            identifier, channel = parse_identifier(serializer.validated_data["identifier"])
        except ValueError as e:
            return Response({"identifier": [str(e)]}, status=400)

        user_exists = User.objects.find_by_identifier(identifier, channel) is not None

        if purpose == OTP.PURPOSE_REGISTER and user_exists:
            return Response(
                {"identifier": ["An account with this email/phone already exists. Please log in instead."]},
                status=400,
            )
        if purpose in (OTP.PURPOSE_LOGIN, OTP.PURPOSE_RESET) and not user_exists:
            return Response({"identifier": ["No account found with this email/phone."]}, status=400)

        otp = create_otp(identifier, channel, purpose)
        send_otp(otp)

        payload = {
            "message": "OTP sent successfully.",
            "channel": channel,
            "expiresInSeconds": int((otp.expires_at - timezone.now()).total_seconds()),
        }
        from django.conf import settings

        if getattr(settings, "OTP_DEBUG_ECHO", False):
            payload["debugOtp"] = otp.code  # DEBUG only - remove/disable in production
        return Response(payload)


class VerifyOTPView(APIView):
    """
    POST /api/auth/verify-otp/  {"identifier": "...", "otp": "1234", "purpose": "register"|"login"}

    - purpose="register": marks the OTP used and returns a
      registration_token (encodes the verified identifier + channel).
      Used by OTPRegister.dart's Verify button.
    - purpose="login": marks the OTP used and logs the user straight in
      (returns JWT tokens + user), matching OTPLogain.dart's Verify button.
    """

    permission_classes = [permissions.AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "otp_verify"

    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        code = serializer.validated_data["otp"]
        purpose = serializer.validated_data["purpose"]

        try:
            identifier, channel = parse_identifier(serializer.validated_data["identifier"])
        except ValueError as e:
            return Response({"identifier": [str(e)]}, status=400)

        otp = (
            OTP.objects.filter(identifier=identifier, purpose=purpose, is_used=False)
            .order_by("-created_at")
            .first()
        )

        if otp is None:
            return Response({"detail": "No active OTP for this email/phone. Please request a new one."}, status=400)

        if otp.is_expired:
            return Response({"detail": "OTP has expired. Please request a new one."}, status=400)

        if otp.attempts >= 5:
            otp.is_used = True
            otp.save(update_fields=["is_used"])
            return Response({"detail": "Too many incorrect attempts. Please request a new OTP."}, status=400)

        if otp.code != code:
            otp.attempts += 1
            otp.save(update_fields=["attempts"])
            return Response({"detail": "Incorrect OTP."}, status=400)

        otp.is_used = True
        otp.save(update_fields=["is_used"])

        if purpose == OTP.PURPOSE_REGISTER:
            return Response(
                {
                    "verified": True,
                    "registrationToken": issue_registration_token(identifier, channel),
                }
            )

        if purpose == OTP.PURPOSE_LOGIN:
            user = User.objects.find_by_identifier(identifier, channel)
            if user is None:
                return Response({"detail": "No account found with this email/phone."}, status=404)

            return Response(
                {
                    "verified": True,
                    **tokens_for_user(user),
                    "user": UserSerializer(user, context={"request": request}).data,
                }
            )

        return Response({"verified": True})


class RegisterView(APIView):
    """
    POST /api/auth/register/  (multipart/form-data)
      registration_token, fullName, dateOfBirth, password, confirmPassword,
      acceptedTerms, acceptedOffers, avatar (optional file),
      email / phoneNumber (both optional extras)

    Final submit, called from avatar_Screen.dart's "Continue" button after
    the whole userInfo -> PassScreen -> avatar_Screen flow completes.
    """

    permission_classes = [permissions.AllowAny]
    parser_classes = [parsers.MultiPartParser, parsers.FormParser, parsers.JSONParser]

    def post(self, request):
        token = request.data.get("registration_token")
        if not token:
            return Response({"registration_token": "This field is required."}, status=400)

        try:
            identifier, channel = read_registration_token(token)
        except signing.SignatureExpired:
            return Response({"detail": "Registration session expired. Please verify your email/phone again."}, status=400)
        except signing.BadSignature:
            return Response({"detail": "Invalid registration token."}, status=400)

        if User.objects.find_by_identifier(identifier, channel) is not None:
            return Response({"identifier": "An account with this email/phone already exists."}, status=400)

        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        create_kwargs = dict(
            password=data["password"],
            full_name=data["full_name"],
            date_of_birth=data.get("date_of_birth"),
            accepted_terms=data["accepted_terms"],
            accepted_offers=data.get("accepted_offers", False),
            email_verified=True,
        )

        # The identifier that was actually OTP-verified always wins its slot.
        if channel == OTP.CHANNEL_EMAIL:
            create_kwargs["email"] = identifier
            create_kwargs["phone_number"] = data.get("phone_number")
        else:
            create_kwargs["phone_number"] = identifier
            create_kwargs["email"] = data.get("email")

        user = User.objects.create_user(**create_kwargs)

        if data.get("avatar"):
            user.avatar = data["avatar"]
            user.save(update_fields=["avatar"])

        return Response(
            {
                **tokens_for_user(user),
                "user": UserSerializer(user, context={"request": request}).data,
            },
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    """
    POST /api/auth/login/  {"identifier": "...", "password": "..."}

    `identifier` is email OR phone number. Matches PasswordLogin.dart's
    Continue button.
    """

    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        password = serializer.validated_data["password"]

        try:
            identifier, channel = parse_identifier(serializer.validated_data["identifier"])
        except ValueError as e:
            return Response({"identifier": [str(e)]}, status=400)

        user = User.objects.find_by_identifier(identifier, channel)
        if user is None or not user.check_password(password):
            return Response({"detail": "Invalid email/phone or password."}, status=401)

        if not user.is_active:
            return Response({"detail": "This account has been disabled."}, status=403)

        return Response(
            {
                **tokens_for_user(user),
                "user": UserSerializer(user, context={"request": request}).data,
            }
        )


class LogoutView(APIView):
    """
    POST /api/auth/logout/

    Blacklists the user's refresh token so it cannot be used again.

    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self , request):
        refresh_token = request.data.get('refresh')

        if not refresh_token:
            return Response(
                {"detail": "Refresh token is required."},
                status = status.HTTP_400_BAD_REQUEST,
            )

        try:
            token = RefreshToken(refresh_token)
            token.blacklist()

            return Response(
                {"message":"Logged out successfully."},
                status=status.HTTP_200_OK,
            )

        except Exception:
            return Response(
                {"detail": "Invalid or already blacklisted refresh token."},
                status=status.HTTP_400_BAD_REQUEST,
            )

class MeView(APIView):
    """GET/PATCH /api/auth/me/ — read or update the logged-in user's profile."""

    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [parsers.MultiPartParser, parsers.FormParser, parsers.JSONParser]

    def get(self, request):
        return Response(UserSerializer(request.user, context={"request": request}).data)

    def patch(self, request):
        user = request.user
        full_name = request.data.get("fullName")
        avatar = request.data.get("avatar")

        if full_name is not None:
            user.full_name = full_name
        if avatar is not None:
            user.avatar = avatar
        user.save()

        return Response(UserSerializer(user, context={"request": request}).data)
