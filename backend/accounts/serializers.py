from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from .models import OTP
from .utils import PHONE_REGEX

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Output shape sent back to Flutter, matching SignUpData naming."""

    fullName = serializers.CharField(source="full_name", read_only=True)
    dateOfBirth = serializers.DateField(source="date_of_birth", read_only=True)
    phoneNumber = serializers.CharField(source="phone_number", read_only=True)
    avatarUrl = serializers.SerializerMethodField()
    acceptedTerms = serializers.BooleanField(source="accepted_terms", read_only=True)
    acceptedOffers = serializers.BooleanField(source="accepted_offers", read_only=True)
    emailVerified = serializers.BooleanField(source="email_verified", read_only=True)

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "phoneNumber",
            "fullName",
            "dateOfBirth",
            "avatarUrl",
            "acceptedTerms",
            "acceptedOffers",
            "emailVerified",
        ]

    def get_avatarUrl(self, obj):
        request = self.context.get("request")
        url = obj.avatar_url
        if url and request is not None:
            return request.build_absolute_uri(url)
        return url


class CheckIdentifierSerializer(serializers.Serializer):
    """Accepts either an email address or a phone number in one field."""

    identifier = serializers.CharField()


class SendOTPSerializer(serializers.Serializer):
    identifier = serializers.CharField()
    purpose = serializers.ChoiceField(choices=OTP.PURPOSE_CHOICES)


class VerifyOTPSerializer(serializers.Serializer):
    identifier = serializers.CharField()
    otp = serializers.CharField(min_length=4, max_length=4)
    purpose = serializers.ChoiceField(choices=OTP.PURPOSE_CHOICES)


class LoginSerializer(serializers.Serializer):
    """Matches PasswordLogin.dart. `identifier` is email OR phone number."""

    identifier = serializers.CharField()
    password = serializers.CharField(write_only=True, trim_whitespace=False)


class RegisterSerializer(serializers.Serializer):
    """
    Final submit from avatar_Screen.dart 'Continue'. Carries everything
    collected across userInfo.dart + PassScreen.dart + avatar_Screen.dart,
    plus the registration_token proving the identifier's OTP was verified.

    The identifier used to sign up (email or phone) comes from the
    registration_token itself. `email` / `phoneNumber` here are OPTIONAL
    extras — e.g. someone who signed up with a phone number can also add
    an email address at this step, and vice versa.
    """

    registration_token = serializers.CharField(write_only=True)
    fullName = serializers.CharField(source="full_name", max_length=150)
    dateOfBirth = serializers.DateField(source="date_of_birth", required=False, allow_null=True)
    password = serializers.CharField(write_only=True, trim_whitespace=False)
    confirmPassword = serializers.CharField(write_only=True, trim_whitespace=False)
    acceptedTerms = serializers.BooleanField(source="accepted_terms")
    acceptedOffers = serializers.BooleanField(source="accepted_offers", required=False, default=False)
    avatar = serializers.ImageField(required=False, allow_null=True)

    email = serializers.EmailField(required=False, allow_null=True, allow_blank=True)
    phoneNumber = serializers.CharField(
        source="phone_number", required=False, allow_null=True, allow_blank=True, max_length=20
    )

    def validate_acceptedTerms(self, value):
        if not value:
            raise serializers.ValidationError("You must accept the Terms & Conditions.")
        return value

    def validate_password(self, value):
        validate_password(value)
        return value

    def validate_phoneNumber(self, value):
        if value and not PHONE_REGEX.match(value.replace(" ", "").replace("-", "")):
            raise serializers.ValidationError("Enter a valid phone number, e.g. +14155551234.")
        return value

    def validate(self, attrs):
        if attrs["password"] != attrs.pop("confirmPassword"):
            raise serializers.ValidationError({"confirmPassword": "Passwords do not match."})

        email = attrs.get("email")
        if email and User.objects.filter(email__iexact=email).exists():
            raise serializers.ValidationError({"email": "This email is already in use."})

        phone_number = attrs.get("phone_number")
        if phone_number and User.objects.filter(phone_number=phone_number).exists():
            raise serializers.ValidationError({"phoneNumber": "This phone number is already in use."})

        return attrs
