import 'package:mydairy/app/config/api_config.dart';
import 'package:mydairy/app/core/services/storage_service.dart';

/// Service to manage API key resolution from multiple sources.
/// Priority: User settings (runtime) > Build-time define > Empty
class ApiKeyService {
  final StorageService _storageService;
  static const String _apiKeyStorageKey = 'groq_api_key';

  ApiKeyService(this._storageService);

  /// Gets the API key with priority:
  /// 1. User-provided key from storage (runtime)
  /// 2. Build-time define (--dart-define)
  /// 3. Empty string (AI features disabled)
  String getApiKey() {
    // First, check if user has provided their own API key
    final userApiKey = _storageService.getString(_apiKeyStorageKey);
    if (userApiKey != null && userApiKey.isNotEmpty) {
      return userApiKey;
    }

    // Fallback to build-time define
    return ApiConfig.groqApiKey;
  }

  /// Sets the API key in user storage (runtime)
  Future<bool> setApiKey(String apiKey) async {
    return await _storageService.setString(_apiKeyStorageKey, apiKey);
  }

  /// Removes the API key from user storage
  Future<bool> removeApiKey() async {
    return await _storageService.remove(_apiKeyStorageKey);
  }

  /// Checks if an API key is configured
  bool isApiKeyConfigured() {
    return getApiKey().isNotEmpty;
  }
}
