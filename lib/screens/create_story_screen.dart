import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../utils/app_theme.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _textController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _charactersController = TextEditingController();
  final _durationController = TextEditingController(text: "15");

  String _generatedPrompt = "";
  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (_categoryController.text.isEmpty) {
        _categoryController.text = args['categoryName'] ?? '';
      }
    }
  }

  Future<void> _generatePrompt() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _generatedPrompt = "";
    });

    try {
      final prompt = await _geminiService.generateVideoPrompt(
        category: _categoryController.text,
        basicText: _textController.text,
        background: _backgroundController.text,
        characters: _charactersController.text,
      );

      setState(() {
        _generatedPrompt = prompt;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _charactersController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Video Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Video Title',
                hint: 'e.g., The Mystery of Mars',
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _categoryController,
                label: 'Category',
                hint: 'e.g., Teaching, Marketing',
                icon: Icons.category,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _textController,
                label: 'Video Description / Idea',
                hint: 'What is the video about?',
                icon: Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _backgroundController,
                      label: 'Background',
                      hint: 'e.g., 3D Studio',
                      icon: Icons.landscape,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      label: 'Duration (sec)',
                      hint: '10-30',
                      icon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _charactersController,
                label: 'Characters (Optional)',
                hint: 'e.g., A robot teacher',
                icon: Icons.people,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generatePrompt,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isLoading ? 'Processing AI...' : 'Generate AI Prompt',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_generatedPrompt.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildPromptResult(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'AI-Optimized Video Prompt:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: SelectableText(
            _generatedPrompt,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Navigate to generation status page
            Navigator.pushNamed(
              context,
              '/video-builder',
              arguments: {
                'prompt': _generatedPrompt,
                'title': _titleController.text,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Start Video Generation'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (label.contains('Optional')) return null;
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
