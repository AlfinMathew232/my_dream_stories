import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
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
  String? _finalVideoUrl; // Placeholder for real URL
  Map<String, dynamic>? _args;

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
    // Simulate FFmpeg stages
    await _updateStatus('Analyzing Script...', 0.1);
    await _updateStatus('Processing Audio...', 0.3);
    await _updateStatus('Composing Scenes...', 0.5);
    await _updateStatus('Rendering Video...', 0.7);
    await _updateStatus('Finalizing...', 0.9);

    // Save to Firestore
    try {
      final user = Provider.of<AuthService>(context, listen: false).user;
      if (user != null && _args != null) {
        // Upload to Storage (Skipped - using placeholder)
        // In real app: VideoService.uploadFile(file);
        _finalVideoUrl =
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'; // Dummy

        await DatabaseService().createVideoRecord(
          uid: user.uid,
          title: _args!['title'] ?? 'Untitled Video',
          category: _args!['category'] ?? 'General',
          description: _args!['script'] ?? '',
          characterId: _args!['characterId'] ?? '0',
          backgroundId: _args!['backgroundId'] ?? '0',
          videoUrl: _finalVideoUrl!,
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }

    await _updateStatus('Complete!', 1.0);

    if (mounted) {
      setState(() {
        _isBuilding = false;
      });
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
                      // Navigate to player or My Videos
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (r) => false,
                      );
                      Navigator.pushNamed(
                        context,
                        '/my-videos',
                      ); // Then push my videos
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
    );
  }
}
