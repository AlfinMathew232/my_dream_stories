import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../services/video_service.dart';

class PromptReviewScreen extends StatefulWidget {
  const PromptReviewScreen({super.key});

  @override
  State<PromptReviewScreen> createState() => _PromptReviewScreenState();
}

class _PromptReviewScreenState extends State<PromptReviewScreen> {
  late TextEditingController _promptController;
  Map<String, dynamic>? _args;
  final VideoService _videoService = VideoService();
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      _args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _promptController = TextEditingController(text: _args?['prompt'] ?? '');
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review AI Prompt'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _args?['title'] ?? 'Untitled Video',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.category,
                      'Category',
                      _args?['category'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      Icons.timer,
                      'Duration',
                      '${_args?['duration'] ?? 10}s',
                    ),
                    _buildInfoRow(
                      Icons.aspect_ratio,
                      'Aspect Ratio',
                      _args?['ratio'] ?? '1280:720',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Prompt Section
            const Text(
              'AI-Generated Video Prompt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review and edit the prompt below before generating your video:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _promptController,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: 'Your AI-generated prompt will appear here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppTheme.primaryColor.withOpacity(0.05),
              ),
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() {
                              _isSaving = true;
                            });

                            try {
                              // Get current user
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                throw Exception('User not logged in');
                              }

                              // Save video data to Firestore
                              final videoId = await _videoService.saveVideoData(
                                userId: user.uid,
                                videoTitle: _args!['title'],
                                category: _args!['category'],
                                description: _args!['description'] ?? '',
                                background: _args!['background'],
                                characters: _args!['characters'],
                                duration: _args!['duration'],
                                aspectRatio: _args!['ratio'],
                                aiGeneratedPrompt: _promptController.text,
                                seed: _args!['seed'],
                              );

                              // Navigate to video builder with video ID
                              if (mounted) {
                                Navigator.pushNamed(
                                  context,
                                  '/video-builder',
                                  arguments: {
                                    ..._args!,
                                    'prompt': _promptController.text,
                                    'videoId': videoId,
                                  },
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error saving video data: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                });
                              }
                            }
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Video Generation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
