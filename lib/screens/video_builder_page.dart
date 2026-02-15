import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/runway_service.dart';
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
  final RunwayService _runwayService = RunwayService();
  final VideoService _videoService = VideoService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      _args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _startBuildProcess();
    }
  }

  Future<void> _startBuildProcess() async {
    final user = Provider.of<AuthService>(context, listen: false).user;
    if (user == null || _args == null) return;

    try {
      // 1. Submit to Runway
      await _updateStatus('Submitting to Runway AI...', 0.1);
      final taskId = await _runwayService.generateVideo(
        prompt: _args!['prompt'] ?? 'A beautiful story video',
        duration: _args!['duration'] ?? 10,
        ratio: _args!['ratio'] ?? '1280:720',
        seed: _args!['seed'],
      );

      // Update Firestore with Runway task ID
      if (_args!['videoId'] != null) {
        await _videoService.updateVideoStatus(
          videoId: _args!['videoId'],
          status: 'generating',
          runwayTaskId: taskId,
        );
      }

      // 2. Poll for Status
      bool isFinished = false;
      while (!isFinished) {
        await Future.delayed(const Duration(seconds: 3));
        final statusData = await _runwayService.checkTaskStatus(taskId);
        final status = statusData['status'];
        final progress = (statusData['progress'] ?? 0.0).toDouble();

        if (status == 'SUCCEEDED') {
          isFinished = true;
          _finalVideoUrl = statusData['output'][0];
          await _updateStatus('Video Generated! Finalizing...', 0.8);
        } else if (status == 'FAILED') {
          throw Exception(
            'Runway Generation Failed: ${statusData['failureCode']}',
          );
        } else {
          await _updateStatus(
            'AI Rendering: ${status.toLowerCase()}...',
            0.1 + (progress * 0.6),
          );
        }
      }

      // 3. Upload to Firebase Storage
      if (_finalVideoUrl != null) {
        await _updateStatus('Optimizing & Storing Video...', 0.9);
        final firebaseRefUrl = await _runwayService.uploadToFirebase(
          runwayUrl: _finalVideoUrl!,
          uid: user.uid,
          title: _args!['title'] ?? 'Untitled Video',
        );

        // 4. Save to Firestore
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

        // Update video status in Firestore
        if (_args!['videoId'] != null) {
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
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
