import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  String? _selectedBackground;
  String? _selectedCharacter;
  double _duration = 15.0; // Changed from Controller to double

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
        background: _selectedBackground ?? '',
        characters: _selectedCharacter ?? '',
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
                readOnly: true,
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
              _buildFirestoreDropdown(
                collection: 'backgrounds',
                label: 'Background',
                icon: Icons.landscape,
                value: _selectedBackground,
                onChanged: (v) => setState(() => _selectedBackground = v),
              ),
              const SizedBox(height: 24),
              _buildDurationSelector(),
              const SizedBox(height: 24),
              _buildFirestoreDropdown(
                collection: 'characters',
                label: 'Characters',
                icon: Icons.people,
                value: _selectedCharacter,
                onChanged: (v) => setState(() => _selectedCharacter = v),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
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
                      label: Text(_isLoading ? 'AI...' : 'Generate AI Prompt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _createDirectly,
                      icon: const Icon(Icons.bolt),
                      label: const Text('Create Directly'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.green),
                        foregroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
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

  Widget _buildFirestoreDropdown({
    required String collection,
    required String label,
    required IconData icon,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<DropdownMenuItem<String>> items = [];
        if (snapshot.hasData) {
          items = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Untitled';
            return DropdownMenuItem<String>(value: name, child: Text(name));
          }).toList();
        }

        return DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: Text('Select $label'),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please select a $label' : null,
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
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

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Video Duration',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_duration.round()} Seconds',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _duration,
          min: 10,
          max: 30,
          divisions: 20,
          activeColor: AppTheme.primaryColor,
          label: '${_duration.round()}s',
          onChanged: (val) => setState(() => _duration = val),
        ),
      ],
    );
  }

  void _createDirectly() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBackground == null || _selectedCharacter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select background and characters'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/video-builder',
      arguments: {
        'prompt': _textController.text, // Use raw text as prompt
        'title': _titleController.text,
        'background': _selectedBackground,
        'character': _selectedCharacter,
        'duration': _duration.round(),
      },
    );
  }
}
