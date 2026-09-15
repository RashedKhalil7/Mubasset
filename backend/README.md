# Mubasset — Auth Backend (Django + DRF)

Backend built to match the Flutter registration/login screens you shared.
Users can register and log in with **either an email address or a phone
number** — the app sends whatever the user typed into one `identifier`
field, and the backend figures out which kind it is and routes OTP delivery
(email vs. SMS) accordingly.

| Flutter screen | Backend endpoint |
|---|---|
| `login.dart` (identifier step) | `POST /api/auth/check-identifier/` |
| `OTPRegister.dart` | `POST /api/auth/send-otp/`, `POST /api/auth/verify-otp/` (purpose=`register`) |
| `userInfo.dart` + `PassScreen.dart` | data collected client-side into `SignUpData` |
| `avatar_Screen.dart` (Continue) | `POST /api/auth/register/` (multipart, final submit) |
| `PasswordLogin.dart` | `POST /api/auth/login/` |
| `OTPLogain.dart` | `POST /api/auth/send-otp/`, `POST /api/auth/verify-otp/` (purpose=`login`) |

All endpoints have been tested end-to-end with real HTTP requests for both
the email path and the phone path (see "Tested flow" below).

## 1. Setup

```bash
cd gharafa_backend
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt

python manage.py migrate
python manage.py createsuperuser   # optional, for /admin/
python manage.py runserver 0.0.0.0:8000
```

Copy `.env.example` to `.env` and adjust if you want real SMTP email, a
different DB, etc. Everything works out of the box with SQLite + console
email (email OTPs print to the terminal) for local development.

### Using MySQL

The project defaults to SQLite (zero config). To use MySQL/MariaDB instead:

1. **Install the client dev headers** the `mysqlclient` Python package needs to build (already in `requirements.txt`):
   ```bash
   # Debian/Ubuntu
   sudo apt-get install default-libmysqlclient-dev pkg-config build-essential
   # macOS (Homebrew)
   brew install mysql-client pkg-config
   # Windows: just `pip install mysqlclient` — wheels are prebuilt
   ```
   Then `pip install -r requirements.txt` (or `pip install mysqlclient` if you'd already installed everything else).

2. **Create the database and a user**, e.g.:
   ```sql
   CREATE DATABASE gharafa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE USER 'gharafa'@'%' IDENTIFIED BY 'your-password';
   GRANT ALL PRIVILEGES ON gharafa.* TO 'gharafa'@'%';
   FLUSH PRIVILEGES;
   ```
   (`utf8mb4` matters — plain `utf8` in MySQL can't store full emoji/some Unicode, and Django's default `CharField` lengths assume it.)

3. **Set these in `.env`** (copy from `.env.example`, already has placeholders):
   ```bash
   DB_ENGINE=mysql
   DB_NAME=gharafa
   DB_USER=gharafa
   DB_PASSWORD=your-password
   DB_HOST=127.0.0.1
   DB_PORT=3306
   ```
   The project auto-loads `.env` via `python-dotenv` (see `config/settings.py`), so no manual `export` needed — just make sure `.env` sits next to `manage.py`.

4. **Run migrations against it**:
   ```bash
   python manage.py migrate
   ```

That's it — every other setting (JWT, OTP, email, CORS) is unaffected; only
`DATABASES` in `config/settings.py` changes based on `DB_ENGINE`. Verified
locally end-to-end: registered and logged in a user through the full
email-OTP flow with `DB_ENGINE=mysql` set, then confirmed the row landed in
MySQL's `accounts_user` table via a direct `SELECT`.

**Switching from an existing SQLite install:** migrations create the same
schema on either backend, but *data* doesn't move automatically. For a
fresh project, just point `DB_ENGINE=mysql` at an empty database and
`migrate`. To carry over existing SQLite data, dump it with
`python manage.py dumpdata --natural-foreign --natural-primary > data.json`
before switching, then `python manage.py loaddata data.json` after
migrating the MySQL database.

**SMS is stubbed.** Phone OTPs are logged (`[SMS OTP] to=... code=...`) via
Python's `logging` instead of actually being texted, so the project runs
with zero external accounts. Wire in a real provider (Twilio, Vonage, AWS
SNS, etc.) in `accounts/utils.py:send_otp_sms()` for production.

Django admin is at `http://127.0.0.1:8000/admin/` — useful for peeking at
users and OTP codes while testing.

### Connecting from the Flutter app

- Android emulator → `http://10.0.2.2:8000`
- iOS simulator → `http://127.0.0.1:8000`
- Real device → your machine's LAN IP, e.g. `http://192.168.1.23:8000`

Ready-made, updated versions of every screen that needed changes are in
`flutter_integration/` — copy them over your existing files (adjust the
`import '../services/api_service.dart'` paths to match your project
structure):

- `api_service.dart` — new, matches every endpoint below
- `login.dart` — accepts email OR phone, calls `check-identifier`
- `OTPRegister.dart` / `OTPLogain.dart` — send/verify real OTPs
- `PasswordLogin.dart` — calls `login`
- `avatar_Screen.dart` — calls `register` with the collected `SignUpData`
- `SignData.dart` — added `phoneNumber` + `registrationToken` fields

## 2. Data model

`accounts.User` (custom user) — mirrors `SignData.dart`. **Either `email` or
`phone_number` must be set (both are optional individually, but at least
one is required)** — enforced in `UserManager.create_user` and the register
serializer.

| Field | Type | Matches |
|---|---|---|
| `email` | unique email, nullable | `email` |
| `phone_number` | unique string, nullable | `phoneNumber` |
| `full_name` | string | `fullName` |
| `date_of_birth` | date, nullable | `dateOfBirth` |
| `avatar` | image upload | `avatarPath` |
| `accepted_terms` | bool | `acceptedTerms` |
| `accepted_offers` | bool | `acceptedOffers` |
| `email_verified` | bool | set true once OTP is verified |
| `password` | hashed (Django's `set_password`) | `password` |

`accounts.OTP` — one-time codes for both register and login, keyed by a
generic `identifier` (email or phone) with a `channel` field (`email` /
`phone`) recording which, plus expiry, usage, and attempt tracking (5 tries
max before it's invalidated).

## 3. API reference

Base URL: `/api/auth/`. Every endpoint below that used to take `email` now
takes `identifier` — a single string that's either an email address or a
phone number (e.g. `+14155551234`). The backend detects which one it is.

### `POST check-identifier/`
```json
// request
{"identifier": "ahmed@gmail.com"}   // or "+97455512345"
// response
{"exists": true, "channel": "email"}   // channel: "email" | "phone"
```
Used right after the user types their identifier in `login.dart`, to route
to `PasswordLogin` (exists) or `OTPRegister` (new).

### `POST send-otp/`
```json
// request
{"identifier": "ahmed@gmail.com", "purpose": "register"}   // or "login"
// response
{"message": "OTP sent successfully.", "channel": "email", "expiresInSeconds": 300, "debugOtp": "1234"}
```
`purpose=register` fails if the identifier is already registered.
`purpose=login` fails if no account exists for it.
`debugOtp` is only included while `DEBUG=True`, so you can test without
reading the console/SMS log — disable `OTP_DEBUG_ECHO` in production.
Rate-limited to 5 requests/minute per IP.

### `POST verify-otp/`
```json
// request
{"identifier": "ahmed@gmail.com", "otp": "1234", "purpose": "register"}
```
- **`purpose=register`** → `{"verified": true, "registrationToken": "..."}`.
  Carry `registrationToken` through the rest of sign-up and send it to
  `register/`. It's valid for 30 minutes and encodes which identifier +
  channel was actually verified.
- **`purpose=login`** → `{"verified": true, "access": "...", "refresh": "...", "user": {...}}`.
  This logs the user in immediately — no separate password step needed,
  matching `OTPLogain.dart`.

Wrong codes are tracked per-OTP (5 attempts max); expired/used codes are rejected.

### `POST register/`  (multipart/form-data)
Final submit from `avatar_Screen.dart`.

| Field | Required | Notes |
|---|---|---|
| `registration_token` | yes | from `verify-otp/` — determines the primary email/phone |
| `fullName` | yes | |
| `dateOfBirth` | no | `YYYY-MM-DD` |
| `password` | yes | Django's validators apply (min 8 chars, not too common, etc.) |
| `confirmPassword` | yes | must match `password` |
| `acceptedTerms` | yes | must be `true` |
| `acceptedOffers` | no | defaults to `false` |
| `avatar` | no | image file |
| `email` | no | optional *extra* — e.g. a phone-verified user adding a backup email |
| `phoneNumber` | no | optional *extra* — the reverse case |

The identifier that was actually OTP-verified (from `registration_token`)
always fills its matching field (`email` if verified by email, `phone_number`
if verified by phone); the plain `email`/`phoneNumber` form fields above are
only used to optionally fill in the *other* one.

Response: `{"access", "refresh", "user": {...}}` (201 Created).

### `POST login/`
```json
{"identifier": "ahmed@gmail.com", "password": "secret123"}
```
Response: `{"access", "refresh", "user": {...}}`. Matches `PasswordLogin.dart`.

### `POST token/refresh/`
```json
{"refresh": "..."}
```
Returns a new `access` token once the old one expires (access tokens live 1
day, refresh tokens 30 days — tune in `SIMPLE_JWT` in `settings.py`).

### `GET /me/`  (requires `Authorization: Bearer <access>`)
Returns the logged-in user's profile, including `phoneNumber`.

### `PATCH /me/`  (requires auth, multipart)
Update `fullName` and/or `avatar`.

All authenticated requests use `Authorization: Bearer <access_token>`.

## 4. Tested flow

Verified locally with `curl` against a running server:

**Email path**
1. `check-identifier` → `{"exists": false, "channel": "email"}` for a new address.
2. `send-otp` (register) → OTP created, debug code returned.
3. `verify-otp` wrong code → rejected; correct code → `registrationToken` issued.
4. `register` (multipart, no avatar) → user created, JWT tokens returned.
5. `check-identifier` → now `true`.

**Phone path**
6. `check-identifier` with `+97455567890` → `{"exists": false, "channel": "phone"}`.
7. Garbage input (`"not-valid"`) → rejected with a clear error.
8. `send-otp` (register, phone) → logged via `[SMS OTP] to=... code=...`, debug code returned.
9. `verify-otp` wrong then correct code → `registrationToken` issued.
10. `register` with only a phone (no email) → user created (`email: null, phoneNumber: "+974..."`).
11. `login` with phone + wrong password → 401; correct password → JWT tokens.
12. `send-otp` (register) on an already-registered phone → rejected.

**Cross-checks**
13. Email registration still works unaffected by the phone changes.
14. Registering a second user with a `phoneNumber` extra field that's
    already taken by the first user → rejected (`"This phone number is
    already in use."`).
15. `GET /me/` with token → profile returned; without token → 401.

## 5. Notes / next steps

- **SMS delivery**: currently just logs the code (see `send_otp_sms` in
  `accounts/utils.py`). Plug in Twilio/Vonage/SNS there for real texts.
- **Phone format**: accepted as an optional `+` followed by 8–15 digits
  (spaces/dashes stripped automatically). Adjust `PHONE_REGEX` in
  `accounts/utils.py` if you need something stricter/looser.
- **Password reset**: the `OTP.PURPOSE_RESET` choice and "Forget Password?"
  link in `PasswordLogin.dart` are scaffolded but not wired to an endpoint
  yet — easy to add following the same `send-otp` / `verify-otp` pattern.
- **Production**: switch `DATABASES` to Postgres, set a real
  `DJANGO_SECRET_KEY`, set `DEBUG=False` (which also turns off
  `debugOtp`), restrict `DJANGO_ALLOWED_HOSTS` and `DJANGO_CORS_ALLOW_ALL`,
  and serve media (avatars) from S3/GCS rather than local disk.
# Curriculum-grounded Arabic tutor

The curriculum API keeps Sudanese third-year secondary books on the server and
uses their extracted text as grounding context for every answer.

1. Install dependencies: `pip install -r requirements.txt`.
2. Copy `backend/.env.example` to `backend/.env`, then replace the
   placeholder with your key. The resulting file is
   `/Users/awabs/FlutterProjects/Mubasset/backend/.env`:

   ```env
   GEMINI_API_KEY=your_actual_gemini_key
   GEMINI_MODEL=gemini-3.6-flash
   ```

   Do not put the key in Flutter files, `mobile/.env`, `pubspec.yaml`, or
   source control. The Django settings file loads this exact `backend/.env`
   file automatically.
3. Run migrations: `python manage.py migrate`.
4. Create an admin user: `python manage.py createsuperuser`.
5. Upload a PDF, TXT, or Markdown book with an authenticated admin request:

   `POST /api/curriculum/upload/` as multipart fields `file`, `title`,
   `subject`, and `grade`.

   For local files, the equivalent command is:
   `python manage.py ingest_curriculum path/to/book.pdf --title "..." --subject "الفيزياء"`.

6. Authenticated students ask questions at `POST /api/curriculum/chat/`:

   `{"message": "اشرح قانون نيوتن الثاني", "history": []}`

PDF pages are split into searchable Arabic/English chunks. Retrieval is
deliberately dependency-light for the first version; a vector index can be
added later when the book collection and usage patterns are known.
