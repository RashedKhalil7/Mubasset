import uuid

from django.conf import settings
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


def avatar_upload_path(instance, filename):
    ext = filename.rsplit(".", 1)[-1] if "." in filename else "jpg"
    return f"avatars/{instance.id}.{ext}"


class UserManager(BaseUserManager):
    """
    Users log in with EITHER email or phone number, matching login.dart's
    "email or phone number" field. At least one of the two must be set.
    """

    use_in_migrations = True

    def create_user(self, email=None, phone_number=None, password=None, **extra_fields):
        if not email and not phone_number:
            raise ValueError("Users must have an email address or a phone number")
        if email:
            email = self.normalize_email(email)
        user = self.model(email=email or None, phone_number=phone_number or None, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("email_verified", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")
        if not email:
            raise ValueError("Superusers must have an email address")

        return self.create_user(email=email, password=password, **extra_fields)

    def find_by_identifier(self, identifier, channel):
        """channel is 'email' or 'phone' (see utils.parse_identifier)."""
        if channel == "email":
            return self.filter(email__iexact=identifier).first()
        return self.filter(phone_number=identifier).first()


class User(AbstractBaseUser, PermissionsMixin):
    """
    Mirrors Login_Feature/Register/data/SignData.dart -> SignUpData:
        fullName, dateOfBirth, acceptedTerms, acceptedOffers, email,
        password, avatarPath.
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    # Either can be null, but at least one must be set (enforced in
    # UserManager.create_user / the registration serializer). unique=True
    # with null=True allows multiple NULLs across different DB backends,
    # so many phone-only users / many email-only users can coexist.
    email = models.EmailField(unique=True, null=True, blank=True)
    phone_number = models.CharField(max_length=20, unique=True, null=True, blank=True)

    full_name = models.CharField(max_length=150, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    avatar = models.ImageField(upload_to=avatar_upload_path, null=True, blank=True)

    accepted_terms = models.BooleanField(default=False)
    accepted_offers = models.BooleanField(default=False)

    email_verified = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return self.email or self.phone_number or str(self.id)

    @property
    def avatar_url(self):
        if self.avatar:
            try:
                return self.avatar.url
            except ValueError:
                return None
        return None


class OTP(models.Model):
    """
    One-time codes used by:
      - OTPRegister.dart  (purpose=register)
      - OTPLogain.dart    (purpose=login)

    `identifier` holds either an email address or a phone number;
    `channel` records which one, so we know whether to deliver the code by
    email or SMS (see utils.send_otp / utils.parse_identifier).
    """

    CHANNEL_EMAIL = "email"
    CHANNEL_PHONE = "phone"
    CHANNEL_CHOICES = [
        (CHANNEL_EMAIL, "Email"),
        (CHANNEL_PHONE, "Phone"),
    ]

    PURPOSE_REGISTER = "register"
    PURPOSE_LOGIN = "login"
    PURPOSE_RESET = "reset"
    PURPOSE_CHOICES = [
        (PURPOSE_REGISTER, "Register"),
        (PURPOSE_LOGIN, "Login"),
        (PURPOSE_RESET, "Reset Password"),
    ]

    identifier = models.CharField(max_length=255, db_index=True)
    channel = models.CharField(max_length=5, choices=CHANNEL_CHOICES)
    code = models.CharField(max_length=4)
    purpose = models.CharField(max_length=10, choices=PURPOSE_CHOICES)

    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    attempts = models.PositiveSmallIntegerField(default=0)

    class Meta:
        indexes = [models.Index(fields=["identifier", "purpose", "is_used"])]
        ordering = ["-created_at"]

    @property
    def is_expired(self):
        return timezone.now() > self.expires_at

    @property
    def is_valid(self):
        return not self.is_used and not self.is_expired

    def __str__(self):
        return f"{self.identifier} [{self.purpose}] {self.code}"
