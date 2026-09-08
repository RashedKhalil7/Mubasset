import logging
import random
import re
from datetime import timedelta

from django.conf import settings
from django.core import signing
from django.core.exceptions import ValidationError as DjangoValidationError
from django.core.mail import send_mail
from django.core.validators import validate_email
from django.utils import timezone

from .models import OTP

logger = logging.getLogger(__name__)

REGISTRATION_TOKEN_SALT = "accounts.registration-token"

# Loose E.164-ish check: optional leading '+', 8-15 digits, no leading 0.
PHONE_REGEX = re.compile(r"^\+?[1-9]\d{7,14}$")


def parse_identifier(value: str):
    """
    Given whatever the user typed into the single "email or phone number"
    field (login.dart), figure out whether it's an email or a phone number.

    Returns (normalized_identifier, channel) where channel is 'email' or
    'phone'. Raises ValueError with a user-facing message if it's neither.
    """
    value = (value or "").strip()

    try:
        validate_email(value)
        return value.lower(), OTP.CHANNEL_EMAIL
    except DjangoValidationError:
        pass

    candidate = value.replace(" ", "").replace("-", "")
    if PHONE_REGEX.match(candidate):
        return candidate, OTP.CHANNEL_PHONE

    raise ValueError("Enter a valid email address or phone number, e.g. +14155551234.")


def generate_otp_code() -> str:
    length = getattr(settings, "OTP_LENGTH", 4)
    return "".join(random.choices("0123456789", k=length))


def create_otp(identifier: str, channel: str, purpose: str) -> OTP:
    """Invalidate any previous unused OTPs for this identifier+purpose, then create a fresh one."""
    OTP.objects.filter(identifier=identifier, purpose=purpose, is_used=False).update(is_used=True)

    expiry_minutes = getattr(settings, "OTP_EXPIRY_MINUTES", 5)
    otp = OTP.objects.create(
        identifier=identifier,
        channel=channel,
        code=generate_otp_code(),
        purpose=purpose,
        expires_at=timezone.now() + timedelta(minutes=expiry_minutes),
    )
    return otp


def _purpose_text(purpose: str) -> str:
    return {
        OTP.PURPOSE_REGISTER: "verify your account and finish signing up",
        OTP.PURPOSE_LOGIN: "log in",
        OTP.PURPOSE_RESET: "reset your password",
    }.get(purpose, "continue")


def send_otp_email(otp: OTP):
    send_mail(
        subject="Your Al Gharafa SC verification code",
        message=(
            f"Your verification code is {otp.code}.\n\n"
            f"Use it to {_purpose_text(otp.purpose)}. It expires in "
            f"{getattr(settings, 'OTP_EXPIRY_MINUTES', 5)} minutes."
        ),
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[otp.identifier],
        fail_silently=True,
    )


def send_otp_sms(otp: OTP):
    """
    Stub SMS sender. Logs the OTP instead of actually sending a text so the
    project runs with zero external accounts out of the box. Wire in a real
    provider (Twilio, Vonage, AWS SNS, etc.) here for production, e.g.:

        client.messages.create(to=otp.identifier, from_=SMS_FROM_NUMBER,
                                body=f"Your code is {otp.code}")
    """
    logger.info("[SMS OTP] to=%s code=%s purpose=%s", otp.identifier, otp.code, otp.purpose)


def send_otp(otp: OTP):
    if otp.channel == OTP.CHANNEL_EMAIL:
        send_otp_email(otp)
    else:
        send_otp_sms(otp)


def issue_registration_token(identifier: str, channel: str) -> str:
    """
    Short-lived signed token proving the identifier's OTP was verified for
    registration. The Flutter app carries this through userInfo ->
    PassScreen -> avatar_Screen and sends it back on final /register/ call,
    so we don't need to re-send/re-check the OTP at every step.
    """
    return signing.dumps({"identifier": identifier, "channel": channel}, salt=REGISTRATION_TOKEN_SALT)


def read_registration_token(token: str):
    """Returns (identifier, channel), or raises signing.BadSignature / SignatureExpired."""
    max_age = getattr(settings, "REGISTRATION_TOKEN_EXPIRY_MINUTES", 30) * 60
    data = signing.loads(token, salt=REGISTRATION_TOKEN_SALT, max_age=max_age)
    return data["identifier"], data["channel"]
