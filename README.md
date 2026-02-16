# My Dream Stories

An AI-powered Flutter application that transforms your creative ideas into engaging video stories. Users can create stories through voice input or text, which are then enhanced by AI and converted into videos.

## Features

- 🎤 **Voice-to-Text Input** - Record your story ideas using speech recognition
- ✍️ **Text Input** - Type your story prompts directly
- 🤖 **AI Story Generation** - Powered by Google Gemini AI for creative story enhancement
- 🎬 **Video Creation** - Automated video generation from stories using Runway ML
- 🔐 **User Authentication** - Secure Firebase authentication
- 💾 **Cloud Storage** - Store and manage your stories in Firebase Firestore
- 💳 **Payment Integration** - Razorpay integration for premium features

## Prerequisites

Before running this project, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.4 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)
- A physical device or emulator for testing

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd my_dream_stories
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Keys

The application requires several API keys to function. You need to create a `lib/api_keys.dart` file with your credentials.

#### Create the API Keys File

Create a new file at `lib/api_keys.dart` with the following structure:

```dart
// SECURITY WARNING: This file should be added to .gitignore
// DO NOT COMMIT THIS FILE TO VERSION CONTROL

class ApiKeys {
  // Google Gemini API Key for AI story generation
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = "YOUR_GEMINI_API_KEY_HERE";
  
  // Runway ML API Key for video generation
  // Get your key from: https://app.runwayml.com/settings/api
  static const String runwayApiKey = "YOUR_RUNWAY_API_KEY_HERE";
  
  // Razorpay API Key for payments (Test or Live)
  // Get your key from: https://dashboard.razorpay.com/app/keys
  static const String razorpayKeyId = "YOUR_RAZORPAY_KEY_ID_HERE";
  
  // Optional: OpenAI API Key (if you want to use GPT instead of Gemini)
  static const String openAiApiKey = "YOUR_OPENAI_KEY_HERE";
}
```

> **⚠️ IMPORTANT**: The `lib/api_keys.dart` file is already added to `.gitignore` and should **NEVER** be committed to version control.

#### Where to Get API Keys

1. **Google Gemini API** (Required)
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Sign in with your Google account
   - Click "Get API key" or "Create API key"
   - Copy the generated key and paste it in `api_keys.dart`
   - **Free tier**: 60 requests per minute

2. **Runway ML API** (Required)
   - Visit [Runway ML](https://runwayml.com/)
   - Create an account and subscribe to a plan
   - Go to [API Settings](https://app.runwayml.com/settings/api)
   - Generate and copy your API key
   - **Pricing**: Starts at $12/month with credits

3. **Razorpay** (Required for payments)
   - Visit [Razorpay Dashboard](https://dashboard.razorpay.com/)
   - Create an account
   - Go to Settings → API Keys
   - Copy your Key ID (use Test mode for development)
   - **Free**: Test mode is free, live mode has transaction fees

For detailed API setup instructions, see [API_SETUP.md](API_SETUP.md).

### 4. Configure Firebase

This app uses Firebase for authentication, database, and storage.

#### Firebase Setup Steps

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" and follow the setup wizard
   - Enable Google Analytics (optional)

2. **Add Android App**
   - In Firebase Console, click "Add app" → Android
   - Register app with package name: `com.example.my_dream_stories` (or your custom package name)
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Add iOS App** (if building for iOS)
   - In Firebase Console, click "Add app" → iOS
   - Register app with bundle ID from `ios/Runner/Info.plist`
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/` directory

4. **Enable Firebase Services**
   - **Authentication**: Enable Email/Password authentication
     - Go to Authentication → Sign-in method
     - Enable "Email/Password"
   - **Firestore Database**: Create a database
     - Go to Firestore Database → Create database
     - Start in test mode (for development)
   - **Storage**: Enable Firebase Storage
     - Go to Storage → Get started
     - Start in test mode (for development)

5. **Update Firebase Security Rules** (for production)
   
   **Firestore Rules** (`firestore.rules`):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /videos/{videoId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == resource.data.userId;
       }
     }
   }
   ```

### 5. Run the Application

#### For Android

```bash
flutter run
```

#### For iOS

```bash
cd ios
pod install
cd ..
flutter run
```

#### Build for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── api_keys.dart            # API keys configuration (not in git)
├── screens/                 # UI screens
│   ├── create_story_screen.dart
│   ├── prompt_review_screen.dart
│   ├── video_builder_page.dart
│   └── profile_screen.dart
├── services/                # Business logic and API services
│   ├── gemini_service.dart  # AI story generation
│   ├── video_service.dart   # Video creation and management
│   └── auth_service.dart    # Firebase authentication
├── models/                  # Data models
└── widgets/                 # Reusable UI components
```

## Key Dependencies

- **firebase_core** (^3.0.0) - Firebase initialization
- **firebase_auth** (^5.0.0) - User authentication
- **cloud_firestore** (^5.0.0) - Cloud database
- **firebase_storage** (^12.0.0) - File storage
- **provider** (^6.1.1) - State management
- **speech_to_text** (^7.3.0) - Voice input
- **razorpay_flutter** (^1.4.1) - Payment processing
- **http** (^1.1.0) - API requests
- **google_fonts** (^6.2.1) - Typography
- **flutter_animate** (^4.5.2) - Animations

For a complete list, see [pubspec.yaml](pubspec.yaml).

## Development Workflow

1. **Create a new feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow Flutter best practices
   - Keep code clean and documented
   - Test on both Android and iOS if possible

3. **Test thoroughly**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

5. **Push and create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Troubleshooting

### Common Issues

1. **"API key invalid" error**
   - Verify you copied the complete API key without extra spaces
   - Check that the key is active in the provider's dashboard
   - Ensure billing is enabled (for some services)

2. **Firebase initialization error**
   - Confirm `google-services.json` is in `android/app/`
   - Verify package name matches Firebase configuration
   - Run `flutter clean` and rebuild

3. **Build failures**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Delete `build` folder and rebuild
   - Check Flutter and Dart SDK versions

4. **Speech-to-text not working**
   - Check microphone permissions in `AndroidManifest.xml` and `Info.plist`
   - Test on a physical device (emulator microphone may not work well)

5. **Video generation fails**
   - Verify Runway ML API key is valid
   - Check your Runway ML account has sufficient credits
   - Monitor API rate limits

### Getting Help

- Check the [API Setup Guide](API_SETUP.md) for detailed API configuration
- Review Flutter documentation: https://docs.flutter.dev/
- Firebase documentation: https://firebase.google.com/docs
- Open an issue in the repository for bugs or feature requests

## Security Notes

- ✅ `lib/api_keys.dart` is in `.gitignore` - never commit this file
- ✅ Use Firebase Security Rules to protect user data
- ✅ Use Razorpay test mode during development
- ✅ Rotate API keys regularly
- ✅ Set up billing alerts to avoid unexpected charges
- ✅ Never hardcode sensitive data in the codebase

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes with clear commit messages
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or support:
- Open an issue in the repository
- Check existing documentation
- Review the API setup guide

---

**Happy Coding! 🚀**
