import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../api_keys.dart';

class VeoService {
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  final String _apiKey = ApiKeys.geminiVideoApiKey;
  final String _model = 'veo-3.1-fast-generate-preview';

  /// Submits a video generation task to Google Veo 3.1 Fast
  Future<String> generateVideo({
    required String prompt,
    int duration = 10,
    String ratio = "16:9",
    int? seed,
  }) async {
    final Map<String, dynamic> body = {
      "instances": [
        {"prompt": prompt},
      ],
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/models/$_model:predictLongRunning'),
      headers: {'x-goog-api-key': _apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['name']; // Operation name (e.g., "operations/abc123")
    } else {
      throw Exception(
        'Failed to submit Veo task: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Polls the status of a Veo operation
  Future<Map<String, dynamic>> checkTaskStatus(String operationName) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$operationName'),
      headers: {'x-goog-api-key': _apiKey},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to check Veo task status: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Extracts video URI from the completed operation response
  String? extractVideoUri(Map<String, dynamic> statusResponse) {
    // Check if operation is done
    if (statusResponse['done'] != true) {
      return null;
    }

    // Try to extract video URI from response
    try {
      // First attempt: videoSamples[0].videoUri
      if (statusResponse['response'] != null &&
          statusResponse['response']['videoSamples'] != null &&
          statusResponse['response']['videoSamples'].isNotEmpty) {
        return statusResponse['response']['videoSamples'][0]['videoUri'];
      }

      // Second attempt: generateVideoResponse.generatedSamples[0].video.uri
      if (statusResponse['response'] != null &&
          statusResponse['response']['generateVideoResponse'] != null &&
          statusResponse['response']['generateVideoResponse']['generatedSamples'] !=
              null &&
          statusResponse['response']['generateVideoResponse']['generatedSamples']
              .isNotEmpty) {
        return statusResponse['response']['generateVideoResponse']['generatedSamples'][0]['video']['uri'];
      }
    } catch (e) {
      print('Error extracting video URI: $e');
    }

    return null;
  }

  /// Downloads video from Veo URI and uploads it to Firebase Storage
  Future<String> uploadToFirebase({
    required String videoUri,
    required String uid,
    required String title,
  }) async {
    // 1. Download video bytes from Veo URI (with API key)
    final videoResponse = await http.get(
      Uri.parse(videoUri),
      headers: {'x-goog-api-key': _apiKey},
    );

    if (videoResponse.statusCode != 200) {
      throw Exception(
        'Failed to download video from Veo: ${videoResponse.statusCode}',
      );
    }

    // 2. Upload to Firebase Storage
    final fileName =
        '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final storageRef = FirebaseStorage.instance.ref().child(
      'videos/$uid/$fileName',
    );

    final uploadTask = storageRef.putData(
      videoResponse.bodyBytes,
      SettableMetadata(contentType: 'video/mp4'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
