class ApiConfig {
  // ============================================================================
  // AI Service API Keys
  // ============================================================================
  // EXAMPLE FILE - Copy this to api_config.dart and add your real API keys
  // NOTE: This example file is deprecated. Use lib/api_keys.dart instead.

  /// Google Gemini API Key for Prompt/Story Generation
  /// Get your API key from: https://makersuite.google.com/app/apikey
  static const String geminiPromptApiKey = 'YOUR_GEMINI_PROMPT_KEY_HERE';

  /// Google Gemini API Key for Video Generation (Veo 3.1)
  /// Get your API key from: https://makersuite.google.com/app/apikey
  /// TIP: You can use the same key as geminiPromptApiKey if you prefer
  static const String geminiVideoApiKey = 'YOUR_GEMINI_VIDEO_KEY_HERE';

  /// Razorpay API Key for payments
  /// Get your API key from: https://dashboard.razorpay.com/app/keys
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID_HERE';

  // ============================================================================
  // API Endpoints (Optional - customize if needed)
  // ============================================================================

  /// Gemini Story Generation API Endpoint
  static const String storyGenerationEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Veo 3.1 Fast Video Generation API Endpoint
  static const String videoGenerationEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/veo-3.1-fast-generate-preview:predictLongRunning';

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Check if all API keys are configured
  static bool get areApiKeysConfigured {
    return geminiPromptApiKey != 'YOUR_GEMINI_PROMPT_KEY_HERE' &&
        geminiVideoApiKey != 'YOUR_GEMINI_VIDEO_KEY_HERE' &&
        razorpayKeyId != 'YOUR_RAZORPAY_KEY_ID_HERE';
  }

  /// Get validation errors for API keys
  static List<String> getValidationErrors() {
    final errors = <String>[];

    if (geminiPromptApiKey == 'YOUR_GEMINI_PROMPT_KEY_HERE') {
      errors.add('Gemini Prompt API key not configured');
    }

    if (geminiVideoApiKey == 'YOUR_GEMINI_VIDEO_KEY_HERE') {
      errors.add('Gemini Video API key not configured');
    }

    if (razorpayKeyId == 'YOUR_RAZORPAY_KEY_ID_HERE') {
      errors.add('Razorpay API key not configured');
    }

    return errors;
  }
}
