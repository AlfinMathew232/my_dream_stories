import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../api_keys.dart';

class RunwayService {
  final String _baseUrl = 'https://api.dev.runwayml.com/v1';
  final String _apiKey = ApiKeys.runwayApiKey;

  /// Submits a video generation task to Runway (gen4.5) - Text to Video
  Future<String> generateVideo({
    required String prompt,
    String? imageUrl,
    int duration = 10,
    String ratio = "1280:720",
    int? seed,
  }) async {
    final Map<String, dynamic> body = {
      "promptText": prompt,
      "model": "gen4.5",
      "duration": duration > 10 ? 10 : duration,
      "ratio": ratio,
    };

    if (seed != null) {
      body["seed"] = seed;
    }

    // NOTE: We're using text_to_video endpoint, not image_to_video
    // So we don't include promptImage at all
    final response = await http.post(
      Uri.parse('$_baseUrl/text_to_video'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'X-Runway-Version': '2024-11-06',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id']; // Task ID
    } else {
      throw Exception(
        'Failed to submit Runway task: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Polls the status of a Runway task
  Future<Map<String, dynamic>> checkTaskStatus(String taskId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tasks/$taskId'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'X-Runway-Version': '2024-11-06',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to check Runway task status: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Downloads video from Runway and uploads it to Firebase Storage
  Future<String> uploadToFirebase({
    required String runwayUrl,
    required String uid,
    required String title,
  }) async {
    // 1. Download video bytes
    final videoResponse = await http.get(Uri.parse(runwayUrl));
    if (videoResponse.statusCode != 200) {
      throw Exception('Failed to download video from Runway');
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
