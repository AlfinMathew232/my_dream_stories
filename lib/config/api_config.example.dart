class ApiConfig {
  // ============================================================================
  // AI Service API Keys
  // ============================================================================
  // EXAMPLE FILE - Copy this to api_config.dart and add your real API keys

  /// Google Cloud Speech-to-Text API Key
  /// Get your API key from: https://console.cloud.google.com/apis/credentials
  static const String speechToTextApiKey = 'YOUR_SPEECH_TO_TEXT_API_KEY_HERE';

  /// Story Generation API Key (e.g., OpenAI GPT or Google Gemini)
  /// For OpenAI: https://platform.openai.com/api-keys
  /// For Google Gemini: https://makersuite.google.com/app/apikey
  static const String storyGenerationApiKey =
      'YOUR_STORY_GENERATION_API_KEY_HERE';

  /// Text+Image to Video API Key (e.g., Runway ML, Stability AI, or similar)
  /// For Runway ML: https://runwayml.com/
  /// For Stability AI: https://platform.stability.ai/
  static const String textImageToVideoApiKey =
      'YOUR_TEXT_IMAGE_TO_VIDEO_API_KEY_HERE';

  // ============================================================================
  // API Endpoints (Optional - customize if needed)
  // ============================================================================

  /// Speech-to-Text API Endpoint
  static const String speechToTextEndpoint =
      'https://speech.googleapis.com/v1/speech:recognize';

  /// Story Generation API Endpoint
  static const String storyGenerationEndpoint =
      'https://api.openai.com/v1/chat/completions';

  /// Text+Image to Video API Endpoint
  static const String textImageToVideoEndpoint =
      'https://api.runwayml.com/v1/generate';

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Check if all API keys are configured
  static bool get areApiKeysConfigured {
    return speechToTextApiKey != 'YOUR_SPEECH_TO_TEXT_API_KEY_HERE' &&
        storyGenerationApiKey != 'YOUR_STORY_GENERATION_API_KEY_HERE' &&
        textImageToVideoApiKey != 'YOUR_TEXT_IMAGE_TO_VIDEO_API_KEY_HERE';
  }

  /// Get validation errors for API keys
  static List<String> getValidationErrors() {
    final errors = <String>[];

    if (speechToTextApiKey == 'YOUR_SPEECH_TO_TEXT_API_KEY_HERE') {
      errors.add('Speech-to-Text API key not configured');
    }

    if (storyGenerationApiKey == 'YOUR_STORY_GENERATION_API_KEY_HERE') {
      errors.add('Story Generation API key not configured');
    }

    if (textImageToVideoApiKey == 'YOUR_TEXT_IMAGE_TO_VIDEO_API_KEY_HERE') {
      errors.add('Text+Image to Video API key not configured');
    }

    return errors;
  }
}
