import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/veo_service.dart';
import '../services/video_service.dart';
import '../utils/app_theme.dart';

class VideoBuilderPage extends StatefulWidget {
  const VideoBuilderPage({super.key});

  @override
  State<VideoBuilderPage> createState() => _VideoBuilderPageState();
}

class _VideoBuilderPageState extends State<VideoBuilderPage> {
  bool _isBuilding = true;
  double _progress = 0.0;
  String _statusMessage = 'Initializing...';
  String? _finalVideoUrl;
  Map<String, dynamic>? _args;
  final VeoService _veoService = VeoService();
  final VideoService _videoService = VideoService();

  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null && !_hasStarted) {
      _args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (_args != null) {
        _hasStarted = true;
        _startBuildProcess();
      }
    }
  }

  Future<void> _startBuildProcess() async {
    final user = Provider.of<AuthService>(context, listen: false).user;
    if (user == null || _args == null) return;

    try {
      print('');
      print('🎬═══════════════════════════════════════════════════════════');
      print('🎬 STARTING VIDEO GENERATION PROCESS');
      print('🎬═══════════════════════════════════════════════════════════');
      print('User ID: ${user.uid}');
      print('Video Title: ${_args!['title'] ?? 'Untitled'}');
      print('Prompt: ${_args!['prompt'] ?? 'N/A'}');
      print('Duration: ${_args!['duration'] ?? 10}s');
      print('Ratio: ${_args!['ratio'] ?? '16:9'}');
      print('Video ID: ${_args!['videoId'] ?? 'N/A'}');
      print('🎬═══════════════════════════════════════════════════════════');
      print('');

      // 1. Submit to Google Veo 3.1 Fast
      await _updateStatus('Submitting to Google Veo AI...', 0.1);
      final operationName = await _veoService.generateVideo(
        prompt: _args!['prompt'] ?? 'A beautiful story video',
        duration: _args!['duration'] ?? 10,
        ratio: _args!['ratio'] ?? '16:9',
        seed: _args!['seed'],
      );

      // Update Firestore with Veo operation name
      if (_args!['videoId'] != null) {
        await _videoService.updateVideoStatus(
          videoId: _args!['videoId'],
          status: 'generating',
          taskId: operationName,
        );
      }

      // 2. Poll for Status
      bool isFinished = false;
      int pollCount = 0;
      while (!isFinished) {
        await Future.delayed(const Duration(seconds: 15));
        final statusData = await _veoService.checkTaskStatus(operationName);
        final isDone = statusData['done'] ?? false;
        pollCount++;

        if (isDone) {
          // Extract video URI from response
          final videoUri = _veoService.extractVideoUri(statusData);
          if (videoUri != null) {
            isFinished = true;
            _finalVideoUrl = videoUri;
            await _updateStatus('Video Generated! Finalizing...', 0.8);
          } else {
            throw Exception(
              'Video generation completed but no video URI found',
            );
          }
        } else if (statusData['error'] != null) {
          throw Exception(
            'Veo Generation Failed: ${statusData['error']['message']}',
          );
        } else {
          // Still processing
          final progress = (pollCount * 0.05).clamp(0.0, 0.6);
          await _updateStatus(
            'AI Rendering video... (${pollCount * 10}s)',
            0.1 + progress,
          );
        }
      }

      // 3. Upload to Firebase Storage
      if (_finalVideoUrl != null) {
        await _updateStatus('Optimizing & Storing Video...', 0.9);
        final firebaseRefUrl = await _veoService.uploadToFirebase(
          videoUri: _finalVideoUrl!,
          uid: user.uid,
          title: _args!['title'] ?? 'Untitled Video',
        );

        // 4. Save to Firestore (Only if new video)
        if (_args!['videoId'] == null) {
          await _updateStatus('Saving to Database...', 0.95);
          await DatabaseService().createVideoRecord(
            uid: user.uid,
            title: _args!['title'] ?? 'Untitled Video',
            category: _args!['category'] ?? 'General',
            description: _args!['description'] ?? '',
            characterId: _args!['characters'] ?? '',
            backgroundId: _args!['background'] ?? '',
            videoUrl: firebaseRefUrl,
          );
        } else {
          // Update video status in Firestore
          await _videoService.updateVideoStatus(
            videoId: _args!['videoId'],
            status: 'completed',
            videoUrl: firebaseRefUrl,
          );
        }
      }

      await _updateStatus('Complete!', 1.0);
      if (mounted) {
        setState(() {
          _isBuilding = false;
        });
      }
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ [VIDEO BUILDER] ERROR OCCURRED');
      print('═══════════════════════════════════════════════════════════');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('───────────────────────────────────────────────────────────');
      print('Stack Trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════════════════════');
      print('');

      // Provide specific error guidance
      String errorGuidance = '';
      if (e.toString().contains('Permission denied') ||
          e.toString().contains('unauthorized') ||
          e.toString().contains('403')) {
        errorGuidance = '''
🔒 FIREBASE STORAGE PERMISSION ERROR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This error occurs when Firebase Storage security rules block the upload.

SOLUTION:
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project
3. Navigate to Storage → Rules
4. Update rules to allow authenticated users to upload:

rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /videos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}

5. Click "Publish" to save the changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
      } else if (e.toString().contains('API key')) {
        errorGuidance = '''
🔑 API KEY ERROR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Check your API keys in lib/api_keys.dart:
- Ensure geminiVideoApiKey is set correctly
- Verify the key has access to Veo 3.1 Fast model
- Check if the key is active in Google AI Studio
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorGuidance = '''
🌐 NETWORK ERROR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Check your internet connection and try again.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
      }

      if (errorGuidance.isNotEmpty) {
        print(errorGuidance);
      }

      if (mounted) {
        setState(() {
          _statusMessage = 'Error: ${e.toString().split('\n').first}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String msg, double prog) async {
    if (!mounted) return;
    setState(() {
      _statusMessage = msg;
      _progress = prog;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isBuilding) ...[
                CircularProgressIndicator(
                  value: _progress,
                  color: AppTheme.secondaryColor,
                  strokeWidth: 6,
                ),
                const SizedBox(height: 24),
                Text(
                  '$_statusMessage ${(_progress * 100).toInt()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ] else ...[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Video Created Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (r) => false,
                        );
                        Navigator.pushNamed(context, '/my-videos');
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Watch Now'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (r) => false,
                        );
                      },
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
