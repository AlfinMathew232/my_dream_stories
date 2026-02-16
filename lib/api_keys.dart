// SECURITY WARNING: This file should be added to .gitignore
// DO NOT COMMIT THIS FILE TO VERSION CONTROL

class ApiKeys {
  // Google Gemini API Key for Prompt/Story Generation
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiPromptApiKey =
      "AIzaSyAeokqi6YQcmbzZsU8k_Bn13JDVBwx7CwI";

  // Google Gemini API Key for Video Generation (Veo 3.1)
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiVideoApiKey =
      "AIzaSyASr-dcO_m7_fL5wlsntLHeBCK2TBCjrnE";

  // Razorpay Test Key
  static const String razorpayKeyId = "rzp_test_1DP5mmOlF5G5ag";

  // Optional: OpenAI API Key (if you want to use GPT for story generation)
  static const String openAiApiKey = "YOUR_OPENAI_KEY_HERE";
}
