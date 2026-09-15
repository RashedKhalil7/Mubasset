# Mubasset

**Mubasset** is an AI-powered learning assistant designed to help students learn, ask questions, practice concepts, and interact with educational content through a simple and accessible application.

The project is built using **Flutter** for the application and **Django + Django REST Framework** for the backend. The current AI chatbot is implemented directly in Flutter and communicates with the **Google Gemini API**.

> **Project status:** Active development

---

## 📱 About Mubasset

Mubasset aims to provide students with a single platform where they can:

* Ask questions and receive AI-generated answers.
* Have conversations with an AI learning assistant.
* Communicate with the assistant in Arabic or English.
* Upload images related to learning content.
* Practice through quizzes.
* Receive personalized learning recommendations.
* Create and manage their accounts.
* Authenticate using email or phone number.

The project is designed with a modular structure so that additional educational and AI features can be added as development continues.

---

# 🏗️ Project Architecture

Mubasset currently consists of two main parts:

```text
Mubasset
│
├── mobile/       # Flutter application
│
└── backend/      # Django REST API
```

The current communication architecture is:

```text
                    ┌─────────────────────┐
                    │    Flutter App      │
                    │                     │
                    │  UI                 │
                    │  Chatbot            │
                    │  Gemini Integration│
                    │  Authentication UI  │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
                    ▼                     ▼
           ┌────────────────┐    ┌────────────────┐
           │ Django Backend │    │ Google Gemini  │
           │                │    │      API       │
           │ Authentication │    │                │
           │ OTP            │    │ AI Responses   │
           │ Users          │    │                │
           │ REST API       │    │                │
           └────────────────┘    └────────────────┘
```

### Flutter

The Flutter application is responsible for:

* User interface
* Navigation
* Authentication screens
* Chat interface
* AI chatbot integration
* Sending messages to Gemini
* Displaying AI responses
* Conversation history during the current session
* Image selection and upload
* Secure storage of authentication tokens

### Django

The Django backend is responsible for:

* User authentication
* User management
* OTP verification
* Registration
* Login
* JWT authentication
* Token refresh
* REST API endpoints
* Database operations
* Backend services

### Google Gemini

The current AI chatbot communicates **directly from Flutter** with the Google Gemini API.

The current implementation is located in the Flutter chat screen and handles:

* Sending user messages
* Sending conversation history
* Receiving Gemini responses
* Displaying AI responses
* Loading states
* Error handling
* Arabic and English conversations

---

# 🤖 AI Chatbot

Mubasset currently includes an AI learning assistant powered by **Google Gemini**.

The AI functionality is currently implemented in Flutter.

The basic flow is:

```text
User
  │
  ▼
Flutter Chat Screen
  │
  ▼
Gemini API
  │
  ▼
AI Response
  │
  ▼
Flutter Chat Screen
```

The chatbot can:

* Answer questions.
* Explain difficult concepts.
* Provide simple examples.
* Maintain conversation context during the current session.
* Respond in Arabic or English depending on the user's language.
* Display responses directly inside the Mubasset chat interface.

The chat interface is being organized into separate components, including:

```text
menu_screen.dart
options_screen.dart
home.dart
```

The main chat screen currently manages the conversation and Gemini communication.

---

# 💬 Chat Interface

The Mubasset chat interface is designed around three main sections:

```text
┌────────────────┬──────────────────────────┬─────────────────┐
│                │                          │                 │
│     Menu       │       Chat Area          │     Options     │
│                │                          │                 │
│  New Chat      │  AI messages             │  Chat Info      │
│  Conversations │  User messages           │  Rename         │
│  History       │                          │  Delete         │
│                │  Message input           │  Settings       │
│                │                          │                 │
└────────────────┴──────────────────────────┴─────────────────┘
```

The interface is being developed using separate Flutter files to keep the code organized and easier to maintain.

---

# 🔐 Authentication

Mubasset supports user authentication using either an **email address or phone number**.

The authentication flow includes:

1. User enters an email or phone number.
2. Flutter sends the identifier to Django.
3. Django determines whether it is an email or phone number.
4. Django sends an OTP.
5. User enters the OTP.
6. Django verifies the OTP.
7. The user can register or log in.
8. JWT tokens are issued.
9. Flutter securely stores the authentication tokens.

---

# 🔑 Authentication API

The Django backend currently provides authentication endpoints such as:

```text
POST /api/auth/check-identifier/
POST /api/auth/send-otp/
POST /api/auth/verify-otp/
```

The backend also supports functionality for:

* User registration
* Password login
* JWT authentication
* Access-token refresh
* Current-user information
* Token blacklisting/logout

The Flutter application communicates with these endpoints through:

```text
mobile/lib/services/api_service.dart
```

---

# 🧠 Current AI Architecture

At the current stage of development, AI requests are made directly from Flutter:

```text
Flutter
   │
   │ HTTP request
   ▼
Google Gemini API
   │
   │ AI response
   ▼
Flutter
```

This allows the chatbot to be developed and tested quickly.

### Production consideration

For a production release, the AI architecture can later be changed to:

```text
Flutter
   │
   ▼
Django API
   │
   ▼
Gemini API
   │
   ▼
Django
   │
   ▼
Flutter
```

This would allow sensitive AI credentials to remain on the server rather than inside the application.

For the current development version, however, the AI integration is intentionally implemented in Flutter.

---

# 📂 Project Structure

A simplified project structure looks like this:

```text
mubasset/
│
├── mobile/
│   │
│   ├── lib/
│   │   │
│   │   ├── Login_Feature/
│   │   │   ├── login.dart
│   │   │   ├── OTPLogain.dart
│   │   │   └── PasswordLogin.dart
│   │   │
│   │   ├── Register/
│   │   │   ├── data/
│   │   │   │   └── SignData.dart
│   │   │   │
│   │   │   └── Presentaion/
│   │   │       ├── register.dart
│   │   │       ├── OTPRregister.dart
│   │   │       ├── userInfo.dart
│   │   │       ├── PassScreen.dart
│   │   │       └── avatar_Screen.dart
│   │   │
│   │   ├── Home_Feature/
│   │   │   └── home.dart
│   │   │
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   │
│   │   └── main.dart
│   │
│   ├── assets/
│   │   └── images/
│   │
│   ├── pubspec.yaml
│   └── ...
│
├── backend/
│   │
│   ├── accounts/
│   ├── manage.py
│   ├── requirements.txt
│   └── ...
│
└── README.md
```

The project structure may change as new features are added.

---

# 🛠️ Technologies

## Frontend

* **Flutter**
* **Dart**
* HTTP
* Flutter Secure Storage
* Flutter SVG
* Image Picker

## Backend

* **Python**
* **Django**
* **Django REST Framework**
* **Simple JWT**
* **SQLite** for development

## AI

* **Google Gemini API**

---

# ⚙️ Getting Started

## 1. Clone the repository

```bash
git clone YOUR_REPOSITORY_URL
cd mubasset
```

---

# 📱 Running the Flutter Application

Go to the Flutter application:

```bash
cd mobile
```

Install dependencies:

```bash
flutter pub get
```

Check available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

For Linux desktop:

```bash
flutter run -d linux
```

---

# 🤖 Running the AI Chatbot

The current Flutter chatbot receives the Gemini API key through a Dart environment variable.

Run the application using:

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_API_KEY
```

Replace:

```text
YOUR_API_KEY
```

with your Gemini API key.

### ⚠️ Important

Never commit your real Gemini API key to GitHub.

The current direct Flutter integration is suitable for development and testing. Before a production release, the AI request should preferably be moved behind the Django backend.

---

# 🐍 Running the Django Backend

Open another terminal:

```bash
cd backend
```

Install the required Python packages:

```bash
pip install -r requirements.txt
```

Run database migrations:

```bash
python manage.py migrate
```

Create a Django administrator:

```bash
python manage.py createsuperuser
```

Start the development server:

```bash
python manage.py runserver
```

The backend will normally be available at:

```text
http://127.0.0.1:8000
```

The Django admin panel:

```text
http://127.0.0.1:8000/admin/
```

---

# 🔗 Connecting Flutter to Django

The backend URL depends on where the Flutter application is running.

### Linux desktop

```text
http://127.0.0.1:8000
```

### Android emulator

```text
http://10.0.2.2:8000
```

### Physical Android device

Use the local IP address of the computer running Django, for example:

```text
http://192.168.x.x:8000
```

The API configuration is managed in:

```text
mobile/lib/services/api_service.dart
```

---

# 🔒 Security

Mubasset uses JWT authentication and secure storage for authentication tokens.

Important security practices:

* Never commit API keys.
* Never commit passwords.
* Never commit production secrets.
* Keep Django secrets outside the repository.
* Use environment variables for sensitive backend configuration.
* Use HTTPS in production.
* Configure CORS correctly before deployment.
* Keep AI credentials on the backend when moving to production.

---

# 🧪 Development Workflow

The current development workflow is:

```text
Flutter UI
    │
    ▼
Flutter functionality
    │
    ▼
Django API
    │
    ▼
Flutter ↔ Django integration
    │
    ▼
Testing
    │
    ▼
Feature improvements
```

For the AI chatbot:

```text
Flutter Chat UI
    │
    ▼
Gemini API
    │
    ▼
AI response
    │
    ▼
Flutter Chat UI
```

---

# 🗺️ Roadmap

## Authentication

* [x] Email/phone identifier
* [x] OTP verification
* [x] JWT authentication
* [x] Token refresh
* [ ] Production SMS provider
* [ ] Production email provider
* [ ] Password reset

## AI Chatbot

* [x] AI chat interface
* [x] Gemini integration
* [x] Conversation history during the current session
* [x] Arabic/English interaction
* [x] Loading state
* [x] Error handling
* [ ] Persistent chat history
* [ ] Chat history database
* [ ] Rename conversations
* [ ] Delete conversations
* [ ] AI-powered summaries
* [ ] Personalized learning assistance

## Educational Features

* [ ] Quiz generation
* [ ] AI-generated practice questions
* [ ] OCR
* [ ] Image-based question solving
* [ ] Educational image analysis
* [ ] Personalized learning paths
* [ ] Student progress tracking
* [ ] Learning recommendations

## Backend

* [x] Django REST API
* [x] Authentication system
* [x] OTP system
* [x] JWT authentication
* [ ] Persistent chat API
* [ ] AI service layer
* [ ] RAG system
* [ ] OCR service
* [ ] Computer vision services
* [ ] Quiz generator

---

# 👥 Project Team

Mubasset is being developed as a collaborative project with responsibilities divided between the application's major components.

```text
Flutter
   │
   └── Mobile application and user experience

Django
   │
   └── Backend, authentication and APIs

AI
   │
   └── Gemini-powered learning assistant
```

This separation allows each part of the project to evolve independently while communicating through well-defined interfaces.

---

# 📌 Project Status

Mubasset is currently under active development.

The project already contains:

* Flutter application
* Django backend
* User authentication
* OTP verification
* JWT authentication
* Flutter ↔ Django API integration
* Gemini-powered AI chatbot
* Chat interface
* Arabic and English AI interaction

The next stages focus on improving the chat experience, connecting the menu and options panels, adding persistent conversations, and expanding Mubasset's educational capabilities.

---

# 🤝 Contributing

If you are working on Mubasset with other developers, create a separate branch for each feature.

For example:

```bash
git checkout -b feature/chat-history
```

After making changes:

```bash
git add .
git commit -m "Add chat history"
git push origin feature/chat-history
```

Before opening a pull request:

1. Test the Flutter application.
2. Test the Django API.
3. Test Flutter ↔ Django communication.
4. Check that existing features still work.
5. Keep commits focused and descriptive.

---

# 📄 License

The project license will be added before the public release.

---

## Mubasset

**An AI-powered learning assistant built to make learning simpler, smarter, and more accessible.**
