/// Build-time API configuration.
/// Used when building APK/IPA with --dart-define=GROQ_API_KEY=your_key
class ApiConfig {
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  static bool get isApiKeyConfigured => groqApiKey.isNotEmpty;
}
