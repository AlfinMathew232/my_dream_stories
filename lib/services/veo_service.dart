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
    print('🎬 [VEO] Submitting video generation request...');
    print('🎬 [VEO] Prompt length: ${prompt.length} characters');
    print('🎬 [VEO] Duration: ${duration}s, Ratio: $ratio');

    final Map<String, dynamic> body = {
      "instances": [
        {"prompt": prompt},
      ],
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/$_model:predictLongRunning'),
        headers: {
          'x-goog-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final operationName = data['name'];
        print('✅ [VEO] Video generation request submitted successfully!');
        print('✅ [VEO] Operation name: $operationName');
        return operationName;
      } else {
        print('❌ [VEO] Failed to submit video generation request');
        print('❌ [VEO] Status code: ${response.statusCode}');
        print('❌ [VEO] Response: ${response.body}');
        throw Exception(
          'Failed to submit Veo task: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [VEO] Exception during video generation request: $e');
      rethrow;
    }
  }

  /// Polls the status of a Veo operation
  Future<Map<String, dynamic>> checkTaskStatus(String operationName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$operationName'),
        headers: {'x-goog-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isDone = data['done'] ?? false;

        if (isDone) {
          print('✅ [VEO] Video generation completed!');
        } else {
          print('⏳ [VEO] Video generation in progress...');
        }

        return data;
      } else {
        print('❌ [VEO] Failed to check task status');
        print('❌ [VEO] Status code: ${response.statusCode}');
        print('❌ [VEO] Response: ${response.body}');
        throw Exception(
          'Failed to check Veo task status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [VEO] Exception during status check: $e');
      rethrow;
    }
  }

  /// Extracts video URI from the completed operation response
  String? extractVideoUri(Map<String, dynamic> statusResponse) {
    // Check if operation is done
    if (statusResponse['done'] != true) {
      return null;
    }

    print('🔍 [VEO] Extracting video URI from response...');

    // Try to extract video URI from response
    try {
      // First attempt: videoSamples[0].videoUri
      if (statusResponse['response'] != null &&
          statusResponse['response']['videoSamples'] != null &&
          statusResponse['response']['videoSamples'].isNotEmpty) {
        final uri = statusResponse['response']['videoSamples'][0]['videoUri'];
        print('✅ [VEO] Video URI found (videoSamples): $uri');
        return uri;
      }

      // Second attempt: generateVideoResponse.generatedSamples[0].video.uri
      if (statusResponse['response'] != null &&
          statusResponse['response']['generateVideoResponse'] != null &&
          statusResponse['response']['generateVideoResponse']['generatedSamples'] !=
              null &&
          statusResponse['response']['generateVideoResponse']['generatedSamples']
              .isNotEmpty) {
        final uri =
            statusResponse['response']['generateVideoResponse']['generatedSamples'][0]['video']['uri'];
        print('✅ [VEO] Video URI found (generateVideoResponse): $uri');
        return uri;
      }

      print('❌ [VEO] Video URI not found in response');
      print('❌ [VEO] Response structure: ${statusResponse.keys.toList()}');
    } catch (e) {
      print('❌ [VEO] Error extracting video URI: $e');
    }

    return null;
  }

  /// Downloads video from Veo URI and uploads it to Firebase Storage
  Future<String> uploadToFirebase({
    required String videoUri,
    required String uid,
    required String title,
  }) async {
    try {
      print('📥 [VEO] Starting video download from Veo...');
      print('📥 [VEO] Video URI: $videoUri');

      // 1. Download video bytes from Veo URI (with API key)
      final videoResponse = await http.get(
        Uri.parse(videoUri),
        headers: {'x-goog-api-key': _apiKey},
      );

      if (videoResponse.statusCode != 200) {
        print('❌ [VEO] Failed to download video from Veo');
        print('❌ [VEO] Status Code: ${videoResponse.statusCode}');
        print('❌ [VEO] Response: ${videoResponse.body}');
        throw Exception(
          'Failed to download video from Veo: ${videoResponse.statusCode}',
        );
      }

      final videoSize = videoResponse.bodyBytes.length;
      print('✅ [VEO] Video downloaded successfully');
      print(
        '✅ [VEO] Video size: ${(videoSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // 2. Upload to Firebase Storage
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final storagePath = 'videos/$uid/$fileName';

      print('📤 [FIREBASE] Starting upload to Firebase Storage...');
      print('📤 [FIREBASE] Path: $storagePath');
      print('📤 [FIREBASE] File: $fileName');

      final storageRef = FirebaseStorage.instance.ref().child(storagePath);

      final uploadTask = storageRef.putData(
        videoResponse.bodyBytes,
        SettableMetadata(contentType: 'video/mp4'),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print(
            '📤 [FIREBASE] Upload progress: ${progress.toStringAsFixed(1)}%',
          );
        },
        onError: (error) {
          print('❌ [FIREBASE] Upload error: $error');
        },
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ [FIREBASE] Upload completed successfully!');
      print('✅ [FIREBASE] Download URL: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ [VEO/FIREBASE] Upload failed with error:');
      print('❌ [VEO/FIREBASE] Error: $e');
      print('❌ [VEO/FIREBASE] Stack trace: $stackTrace');

      // Provide helpful error messages based on error type
      if (e.toString().contains('Permission denied') ||
          e.toString().contains('unauthorized') ||
          e.toString().contains('403')) {
        print('');
        print('🔒 [FIREBASE] PERMISSION ERROR DETECTED!');
        print(
          '🔒 [FIREBASE] This is likely a Firebase Storage security rules issue.',
        );
        print(
          '🔒 [FIREBASE] Please update your Firebase Storage rules to allow uploads.',
        );
        print('🔒 [FIREBASE] Path attempted: videos/$uid/');
        print('');
      }

      rethrow;
    }
  }
}
