# Mubasset

Mubasset is an AI-powered learning assistant for students. It combines a
Flutter client with a Django REST API for authentication and a
retrieval-augmented learning chat service grounded in imported textbook
content.

## Repository Layout

```text
mubasset/
├── mobile/       # Flutter application
└── backend/      # Django REST API
```

## Features

- Email and phone identifier checks
- OTP-based registration and login
- JWT access and refresh tokens
- Secure token storage in the Flutter app
- Arabic and English learning conversations
- Textbook-aware answers through the learning API
- User avatars and profile management

## Requirements

- Flutter SDK compatible with Dart `3.13.0` or newer
- Python 3.12+ recommended
- A Gemini API key for the learning chat service
- SQLite for the default local database, or MySQL/MariaDB for deployment

## Backend Setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

The API runs at `http://127.0.0.1:8000` by default. Create an administrator
with `python manage.py createsuperuser` when needed.

Create `backend/.env` for local configuration. At minimum, configure the AI
provider:

```dotenv
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL=gemini-2.5-flash
```

The development email backend can print OTP messages in the Django terminal.
Configure SMTP variables in `.env` when real email delivery is required. Do
not commit `.env`, API keys, passwords, or Django secret keys.

## Mobile Setup

In another terminal:

```bash
cd mobile
flutter pub get
flutter devices
flutter run
```

The Flutter app uses the backend URL configured in
`mobile/lib/services/api_service.dart`. Use these host addresses when running
the backend locally:

| Client | Backend URL |
| --- | --- |
| Linux desktop | `http://127.0.0.1:8000` |
| Android emulator | `http://10.0.2.2:8000` |
| Physical device | `http://<computer-lan-ip>:8000` |

## API Endpoints

Authentication is available under `/api/auth/`:

```text
POST /api/auth/check-identifier/
POST /api/auth/send-otp/
POST /api/auth/verify-otp/
POST /api/auth/register/
POST /api/auth/login/
POST /api/auth/logout/
POST /api/auth/token/refresh/
GET  /api/auth/me/
```

Learning chat is available at:

```text
POST /api/learning/chat/
```

Authenticated chat requests can use recent conversation context. Guest requests
can query imported textbook content, but their conversations are not saved.

## Development Checks

Run backend checks with:

```bash
cd backend
python manage.py check
```

Run Flutter analysis and tests with:

```bash
cd mobile
flutter analyze
flutter test
```

## Security Notes

- Keep all secrets in environment variables.
- Rotate any credential that has been exposed or committed accidentally.
- Use a strong `DJANGO_SECRET_KEY` and restrict `DJANGO_ALLOWED_HOSTS` in
  production.
- Replace permissive development CORS settings before deployment.
- Serve the API over HTTPS in production.

## Status

Mubasset is under active development. The project currently focuses on the
Flutter learning experience, authentication, and the Django textbook-grounded
chat service.
