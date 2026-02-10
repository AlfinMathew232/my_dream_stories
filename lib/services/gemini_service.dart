import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = "AIzaSyA_Z1VDRtezIQ7ZvSi1EhifLLhSi28g1rA";
  final String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  Future<String> generateVideoPrompt({
    required String category,
    required String basicText,
    required String background,
    required String characters,
  }) async {
    final prompt =
        "Create a detailed prompt for generating a video (below 30 seconds) based on the following:\n"
        "Category: $category\n"
        "Basic Text: $basicText\n"
        "Background: $background\n"
        "Characters: $characters\n\n"
        "The output should be a single coherent paragraph describing the video scene, valid for a video generation AI.";

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return "No response generated.";
        }
      } else {
        throw Exception(
          'Failed to generate prompt: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error calling Gemini API: $e');
    }
  }
}
