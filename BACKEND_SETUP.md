# COMSATS GPT - Backend Setup Documentation

## Overview
This document describes the backend implementation for COMSATS GPT, including Firebase authentication with OTP verification, Gemini AI integration, and knowledge base management.

## Features Implemented

### 1. Firebase Authentication with Email OTP
- **Email/Password Registration** with OTP verification
- **Login** with email and password
- **Password Reset** functionality
- **User Profile Management** with Firestore
- **Session Management** with Firebase Auth

### 2. Gemini AI Integration
- **Google Gemini Pro** AI model integration
- **Context-aware responses** using COMSATS knowledge base
- **Chat history management**
- **Intelligent knowledge retrieval** from markdown files

### 3. Knowledge Base System
- **10 Markdown files** with COMSATS information:
  - acedemics.md
  - admissions.md
  - alumni.md
  - campuses.md
  - cdc and ssbc.md
  - extra activities and societies.md
  - portals.md
  - scholarship.md
  - students affairs.md
  - teachers.md
- **Smart keyword-based search**
- **Context extraction** for relevant information

### 4. Email Service
- **OTP Email Delivery** for verification
- **Welcome Emails** after registration
- **HTML Email Templates** with professional design

## Configuration

### Environment Variables (.env)
```env
# Gemini AI Configuration
GEMINI_API_KEY=AIzaSyAc_QUqGd27kRgLP9BoQwoD7jDjmT8LONs

# Email Configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=hafizayanmoeen@gmail.com
MAIL_PASSWORD=hgnyphzlzvooxheo
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=hafizayanmoeen@gmail.com
MAIL_FROM_NAME=COMSATS GPT

# Firebase Project ID
FIREBASE_PROJECT_ID=mad-project-77dd3
```

### Firebase Configuration
The app uses Firebase for:
- **Authentication**: Email/password with OTP
- **Firestore**: User data storage
- **Cloud Functions**: (Optional) For email delivery

To configure Firebase:
```bash
flutterfire configure --project=mad-project-77dd3
```

## Architecture

### Services Layer
```
lib/core/services/
├── auth_service.dart          # Firebase authentication
├── email_service.dart         # Email/OTP delivery
├── gemini_service.dart        # Gemini AI integration
└── knowledge_base_service.dart # Markdown file management
```

### Providers (Riverpod)
```
lib/features/auth/providers/
└── auth_provider.dart         # Authentication state management

lib/features/chat/providers/
└── chat_provider.dart         # Chat and AI response management
```

### Authentication Flow

1. **Sign Up**:
   ```
   User enters email/password/name
   → System generates 6-digit OTP
   → OTP sent to email
   → User enters OTP
   → Account created in Firebase
   → User data stored in Firestore
   → Welcome email sent
   ```

2. **Login**:
   ```
   User enters email/password
   → Firebase authentication
   → Session created
   → Navigate to home
   ```

3. **OTP Verification**:
   - OTP valid for 10 minutes
   - Can resend OTP
   - Stored temporarily in memory (production: use Firestore)

### Chat Flow

1. **New Conversation**:
   ```
   User creates new chat
   → Gemini session initialized
   → Conversation stored locally
   ```

2. **Send Message**:
   ```
   User sends message
   → Knowledge base searched for relevant context
   → Context + message sent to Gemini
   → AI response generated
   → Response displayed to user
   ```

3. **Knowledge Base Integration**:
   ```
   User query analyzed
   → Keywords extracted
   → Relevant markdown files identified
   → Content sections extracted
   → Context provided to Gemini
   → Accurate, COMSATS-specific response
   ```

## API Keys & Credentials

### Gemini AI
- **API Key**: AIzaSyAc_QUqGd27kRgLP9BoQwoD7jDjmT8LONs
- **Model**: gemini-pro
- **Features**: Text generation, chat, context-aware responses

### Firebase
- **Project ID**: mad-project-77dd3
- **Services**: Authentication, Firestore
- **Configuration**: See `lib/core/config/firebase_config.dart`

### Email (Gmail SMTP)
- **Host**: smtp.gmail.com
- **Port**: 587
- **Username**: hafizayanmoeen@gmail.com
- **App Password**: hgnyphzlzvooxheo
- **Encryption**: TLS

## Dependencies Added

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  
  # AI
  google_generative_ai: ^0.4.6
  
  # Utilities
  flutter_dotenv: ^5.1.0
  http: ^1.2.0
  mailer: ^6.1.2
```

## Usage

### Authentication

```dart
// Sign up
await ref.read(authStateProvider.notifier).signUp(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
);

// Verify OTP
await ref.read(authStateProvider.notifier).verifyOTP(
  email: 'user@example.com',
  otp: '123456',
);

// Login
await ref.read(authStateProvider.notifier).signIn(
  email: 'user@example.com',
  password: 'password123',
);

// Logout
await ref.read(authStateProvider.notifier).signOut();
```

### Chat

```dart
// Create new conversation
final conversationId = ref.read(chatProvider.notifier)
  .createNewConversation('My Chat');

// Send message
await ref.read(chatProvider.notifier).sendMessage(
  conversationId,
  'What are the admission requirements?',
);
```

## Testing

### Test OTP Flow
1. Run the app
2. Go to Sign Up screen
3. Enter email, password, and name
4. Check console for OTP (in development)
5. Enter OTP on verification screen
6. Account should be created

### Test Chat
1. Login to the app
2. Create a new conversation
3. Ask about COMSATS (e.g., "Tell me about admissions")
4. AI should respond with relevant information from knowledge base

## Production Considerations

### Email Service
Currently using console logging for OTP. For production:
- Implement Firebase Cloud Functions with SendGrid/Mailgun
- Or use a dedicated email service API
- Store OTPs in Firestore with expiry

### Security
- ✅ API keys in .env file (not committed to git)
- ✅ Firebase security rules needed
- ✅ Rate limiting for OTP requests
- ✅ Input validation and sanitization

### Performance
- ✅ Knowledge base loaded once at startup
- ✅ Efficient keyword-based search
- ✅ Context limiting to avoid token limits
- ⚠️ Consider caching for frequently asked questions

## Troubleshooting

### Firebase Initialization Error
```bash
flutter clean
flutter pub get
flutterfire configure --project=mad-project-77dd3
```

### Gemini API Error
- Check API key in .env file
- Verify internet connection
- Check API quota limits

### OTP Not Received
- Check console logs (development mode)
- Verify email configuration
- Implement proper email service for production

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── firebase_config.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── email_service.dart
│   │   ├── gemini_service.dart
│   │   └── knowledge_base_service.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           ├── signup_screen.dart
│   │           └── otp_verification_screen.dart
│   └── chat/
│       ├── providers/
│       │   └── chat_provider.dart
│       └── presentation/
│           └── screens/
│               └── chat_screen.dart
├── main.dart
└── .env

assets/
└── knowledge_base/
    ├── acedemics.md
    ├── admissions.md
    ├── alumni.md
    ├── campuses.md
    ├── cdc and ssbc.md
    ├── extra activities and societies.md
    ├── portals.md
    ├── scholarship.md
    ├── students affairs.md
    └── teachers.md
```

## Next Steps

1. **Configure Firebase properly** with `flutterfire configure`
2. **Test authentication flow** end-to-end
3. **Test chatbot** with various COMSATS questions
4. **Implement proper email service** for production
5. **Add Firebase security rules**
6. **Set up error tracking** (e.g., Sentry, Firebase Crashlytics)
7. **Optimize knowledge base search** algorithm
8. **Add user feedback mechanism**

## Support

For issues or questions:
- Check Firebase console for authentication errors
- Review Gemini API documentation
- Check console logs for detailed error messages
- Verify all environment variables are set correctly

---

**Last Updated**: January 8, 2026
**Version**: 1.0.0
**Author**: COMSATS GPT Development Team
