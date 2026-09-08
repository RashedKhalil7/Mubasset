from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import OTP, User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    ordering = ["-created_at"]
    list_display = [
        "email",
        "phone_number",
        "full_name",
        "email_verified",
        "is_active",
        "is_staff",
        "created_at",
    ]
    list_filter = ["email_verified", "is_active", "is_staff", "accepted_offers"]
    search_fields = ["email", "phone_number", "full_name"]
    readonly_fields = ["id", "created_at", "updated_at", "last_login"]

    fieldsets = (
        (None, {"fields": ("email", "phone_number", "password")}),
        ("Profile", {"fields": ("full_name", "date_of_birth", "avatar")}),
        ("Consent", {"fields": ("accepted_terms", "accepted_offers")}),
        (
            "Status",
            {
                "fields": (
                    "email_verified",
                    "is_active",
                    "is_staff",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                )
            },
        ),
        ("Important dates", {"fields": ("last_login", "created_at", "updated_at")}),
    )
    add_fieldsets = (
        (None, {"classes": ("wide",), "fields": ("email", "phone_number", "password1", "password2")}),
    )


@admin.register(OTP)
class OTPAdmin(admin.ModelAdmin):
    list_display = ["identifier", "channel", "purpose", "code", "is_used", "attempts", "created_at", "expires_at"]
    list_filter = ["purpose", "channel", "is_used"]
    search_fields = ["identifier"]
    readonly_fields = ["created_at"]
