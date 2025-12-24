# 📔 AI Diary & Mood Tracker

A private, secure Flutter mobile app where users write daily diary entries with AI-powered mood analysis, personalized recommendations, and mood trend insights using Groq's free text LLMs.

## 🎯 Features

### Core Features (MVP - Complete ✅)

- **Daily Diary Editor** - Write entries with title, body, and optional tags
- **AI Analysis** - Powered by Groq (Llama 3.3 70B):
  - Automatic mood classification (Happy, Sad, Angry, Anxious, Neutral, Motivated)
  - Entry summarization
  - Personalized recommendations (3 actionable activities under 15 minutes)
  - Empathetic response messages
  - Safety detection for self-harm content
- **Mood Timeline** - Calendar view with mood indicators
- **Analytics Dashboard** -
  - Mood distribution charts (pie chart & breakdown)
  - Weekly/monthly statistics
  - Current writing streak tracker
  - Top moods analysis
- **Local Encrypted Storage** - All data stored locally with Hive
- **Background AI Queue** - Automatic processing of pending analyses
- **Dark/Light Themes** - System-adaptive theming

### Privacy & Security

- **Local-first** - All diary data stored on device
- **No account required** - Completely private
- **AES encryption ready** - Infrastructure for data encryption
- **Biometric unlock** - Ready for implementation
- **No auto-upload** - User controls all data

## 🏗️ Architecture

This app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── app/
│   ├── config/           # DI, routing, themes, localization
│   │   ├── di/          # GetIt dependency injection
│   │   ├── routes/      # GoRouter navigation
│   │   ├── themes/      # Material 3 theming
│   │   └── l10n/        # Internationalization
│   └── core/
│       ├── constants/   # App constants
│       ├── enums/       # Mood types, etc.
│       ├── extensions/  # Dart extensions
│       ├── services/    # Core services (storage, AI queue)
│       ├── utils/       # Utilities & error handling
│       └── widgets/     # Reusable UI components
│
├── data/                # Data Layer
│   ├── datasources/    # Local (Hive) & Remote (Groq API)
│   ├── models/         # Hive models with adapters
│   └── repo/           # Repository implementations
│
├── domain/             # Domain Layer (Business Logic)
│   ├── entities/      # Pure business objects
│   ├── repositories/  # Abstract repository contracts
│   └── usecases/      # Business use cases
│
└── screens/           # Presentation Layer
    ├── home/         # Timeline with calendar
    ├── write_entry/  # Create/edit entries
    ├── entry_detail/ # View entry with AI analysis
    ├── analytics/    # Mood trends & charts
    ├── settings/     # App configuration
    └── splash/       # Initial screen
```

## 📦 Tech Stack

### Core
- **Flutter 3.9+** - Cross-platform framework
- **Dart 3.9+** - Programming language

### State Management
- **flutter_bloc (Cubit)** - Predictable state management
- **Equatable** - Value equality

### Dependency Injection
- **get_it** - Service locator pattern

### Navigation
- **go_router** - Declarative routing with deep linking

### Local Database
- **Hive** - Fast, lightweight NoSQL database
- **hive_flutter** - Flutter integration
- **hive_generator** - Code generation for adapters

### AI Integration
- **Dio** - HTTP client for Groq API
- **Groq API** - Llama 3.3 70B model for text analysis

### Charts & Visualization
- **fl_chart** - Beautiful, customizable charts
- **table_calendar** - Calendar widget with events

### UI Components
- **Material 3** - Modern design system
- **flutter_slidable** - Swipe actions

### Utilities
- **intl** - Internationalization & date formatting
- **uuid** - Unique ID generation
- **dartz** - Functional programming (Either type)
- **shared_preferences** - Key-value storage
- **package_info_plus** - App metadata

### Security (Ready)
- **encrypt** - AES encryption
- **local_auth** - Biometric authentication

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- Groq API key (free at [https://console.groq.com](https://console.groq.com))

### Installation

1. **Clone the repository**
   ```bash
   cd mydairy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure your Groq API key**

   The app supports multiple methods for API key configuration:

   **Method 1: VS Code Debug (Recommended for Development)**
   
   The `.vscode/launch.json` is configured to use the `GROQ_API_KEY` environment variable:
   
   1. Set the environment variable in your terminal:
      ```bash
      # macOS/Linux
      export GROQ_API_KEY=your_groq_api_key_here
      
      # Windows (PowerShell)
      $env:GROQ_API_KEY="your_groq_api_key_here"
      ```
   
   2. Restart VS Code to pick up the environment variable
   
   3. Use the debug configurations: "Launch development", "Launch staging", or "Launch production"
   
   See `.vscode/README.md` for detailed setup instructions.

   **Method 2: Command Line (Build-time)**
   
   Pass the API key during build using `--dart-define`:
   ```bash
   # For development
   flutter run --dart-define=GROQ_API_KEY=your_groq_api_key_here
   
   # For release APK
   flutter build apk --dart-define=GROQ_API_KEY=your_groq_api_key_here
   
   # For release IPA (iOS)
   flutter build ipa --dart-define=GROQ_API_KEY=your_groq_api_key_here
   ```

   **Method 3: Runtime (User-provided)**
   
   Users can also provide their own API key through the app settings (if implemented). The app will prioritize user-provided keys over build-time keys.

   **Note**: 
   - Never commit your API key to version control
   - The app will work without an API key, but AI analysis features will be disabled
   - Get a free API key at [https://console.groq.com](https://console.groq.com)

5. **Run the app**
   
   **VS Code**: Use the debug panel and select a launch configuration
   
   **Command Line**:
   ```bash
   flutter run --dart-define=GROQ_API_KEY=your_groq_api_key_here
   ```

## 📱 App Flow

1. **Splash Screen** → Auto-navigates to Home
2. **Home Screen** → View entries by date with calendar
3. **Write Entry** → Create new diary entry
4. **AI Analysis** → Automatic mood detection & recommendations
5. **Entry Detail** → View full entry with AI insights
6. **Analytics** → Track mood trends over time
7. **Settings** → Configure app preferences

## 🔧 Configuration

### Groq API Settings

The app uses Groq's API for AI analysis. Key configuration in `lib/data/datasources/groq_remote_datasource.dart`:

```dart
static const String baseUrl = 'https://api.groq.com/openai/v1';
static const String model = 'llama-3.3-70b-versatile';
```

### AI Prompt Configuration

Optimized prompts are defined in the `GroqRemoteDataSourceImpl` class:
- **Temperature**: 0.1 (deterministic)
- **Max Tokens**: 400
- **Output Format**: Structured JSON

### Background Queue

AI analysis runs automatically every 30 seconds for pending entries. Configure in `lib/app/core/services/ai_analysis_queue_service.dart`:

```dart
Timer.periodic(
  const Duration(seconds: 30), // Adjust interval here
  (_) => _processQueue(),
);
```

## 📊 Data Models

### DiaryEntry
```dart
{
  id: String (UUID)
  date: DateTime
  title: String
  body: String
  tags: List<String>
  aiSummary: String?
  aiMood: MoodType?
  aiConfidence: double?
  aiRecommendations: List<String>?
  aiEmpathy: String?
  createdAt: DateTime
  updatedAt: DateTime
  isPendingAnalysis: bool
  hasSafetyAlert: bool
}
```

### Mood Types
- 😊 Happy (#FFD700)
- 😢 Sad (#4169E1)
- 😠 Angry (#DC143C)
- 😰 Anxious (#FF6347)
- 😐 Neutral (#808080)
- 💪 Motivated (#32CD32)

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run with coverage
```bash
flutter test --coverage
```

### Analyze code
```bash
flutter analyze
```

## 🛣️ Roadmap

### Phase 2 (Post-MVP)
- [ ] Sentiment trend insights with correlative suggestions
- [ ] Weekly AI-generated mood reflection prompts
- [ ] Export summaries to share with therapist
- [ ] Cloud sync with encryption
- [ ] Multiple diary support
- [ ] Voice-to-text entry
- [ ] Photo attachments
- [ ] Reminder notifications

### Phase 3 (Advanced)
- [ ] Offline AI model (on-device inference)
- [ ] Multi-language support
- [ ] Data export (PDF, JSON, CSV)
- [ ] Mood patterns visualization
- [ ] Integration with health apps
- [ ] Custom mood types

## 🔐 Privacy & Safety

### Data Privacy
- ✅ All data stored locally on device
- ✅ No user accounts or authentication
- ✅ No analytics or tracking
- ✅ API calls to Groq only for AI analysis
- ✅ Entry content not stored on servers

### Safety Features
- ✅ Automatic detection of self-harm content
- ✅ Crisis resource suggestions when needed
- ✅ Clear disclaimers about non-medical use
- 📋 Emergency helpline links (to be added)

**Important**: This app is NOT a replacement for professional mental health care. If you're experiencing crisis, please contact:
- National Suicide Prevention Lifeline: 988
- Crisis Text Line: Text HOME to 741741

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Groq** for providing fast, free LLM inference
- **Flutter community** for excellent packages
- **Clean Architecture** patterns by Robert C. Martin
- Mental health awareness organizations

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Email: your-email@example.com

---

**Made with ❤️ using Flutter & Groq AI**

*Last updated: November 2025*
