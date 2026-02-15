import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gemini_service.dart';
import '../services/video_service.dart';
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
  final _promptController = TextEditingController();
  final _manualBackgroundController = TextEditingController();
  final _manualCharacterController = TextEditingController();

  List<Map<String, dynamic>> _selectedCharacters =
      []; // { 'name': String, 'quantity': int }
  String? _selectedBackground;
  String? _selectedCategory;
  String _selectedRatio = "1280:720";
  bool _useManualBackground = false;
  bool _useManualCharacter = false;

  double _duration = 10.0; // Fixed assertion error (must be within [5, 10])

  bool _isLoading = false;
  final GeminiService _geminiService = GeminiService();
  final VideoService _videoService = VideoService();

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
      _promptController.clear();
    });

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check for duplicate title
      final isDuplicate = await _videoService.checkDuplicateTitle(
        user.uid,
        _titleController.text.trim(),
      );

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You already have a video with the title "${_titleController.text}". Please use a different title.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      String charInfo = "";
      if (_useManualCharacter) {
        charInfo = _manualCharacterController.text;
      } else {
        charInfo = _selectedCharacters
            .map((c) => "${c['name']} (Quantity: ${c['quantity']})")
            .join(", ");
      }

      String bgInfo = _useManualBackground
          ? _manualBackgroundController.text
          : (_selectedBackground ?? '');

      final prompt = await _geminiService.generateVideoPrompt(
        category: _categoryController.text,
        basicText: _textController.text,
        background: bgInfo,
        characters: charInfo,
        videoTitle: _titleController.text,
        duration: _duration.round(),
      );

      print("✅ Gemini Response Received:");
      print("Prompt length: ${prompt.length} characters");
      print(
        "Prompt preview: ${prompt.substring(0, prompt.length > 100 ? 100 : prompt.length)}...",
      );

      setState(() {
        _promptController.text = prompt;
      });

      // Navigate to prompt review screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/prompt-review',
          arguments: {
            'prompt': prompt,
            'title': _titleController.text,
            'category': _categoryController.text,
            'description': _textController.text,
            'duration': _duration.round(),
            'ratio': _selectedRatio,
            'background': _useManualBackground
                ? _manualBackgroundController.text
                : (_selectedBackground ?? ''),
            'characters': _useManualCharacter
                ? _manualCharacterController.text
                : _selectedCharacters
                      .map((c) => "${c['name']} (${c['quantity']})")
                      .join(", "),
            'seed': DateTime.now().millisecondsSinceEpoch % 1000000000,
          },
        );
      }
    } catch (e) {
      print("❌ Error generating prompt: $e");
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
    _promptController.dispose();
    _manualBackgroundController.dispose();
    _manualCharacterController.dispose();
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
              _buildFirestoreDropdown(
                collection: 'categories',
                label: 'Category',
                icon: Icons.category,
                value: _selectedCategory,
                onChanged: (v) {
                  setState(() {
                    _selectedCategory = v;
                    if (v != null) _categoryController.text = v;
                  });
                },
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
              _buildBackgroundSection(),
              const SizedBox(height: 24),
              _buildDurationSelector(),
              const SizedBox(height: 24),
              _buildRatioSelector(),
              const SizedBox(height: 24),
              _buildCharactersSection(),
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
              if (_promptController.text.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildPromptResult(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Background',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _useManualBackground = !_useManualBackground),
              icon: Icon(_useManualBackground ? Icons.list : Icons.edit),
              label: Text(_useManualBackground ? 'Predefined' : 'Manual'),
            ),
          ],
        ),
        if (_useManualBackground)
          _buildTextField(
            controller: _manualBackgroundController,
            label: 'Describe Background',
            hint: 'e.g., A futuristic underwater city with neon lights',
            icon: Icons.landscape,
          )
        else
          _buildFirestoreDropdown(
            collection: 'backgrounds',
            label: 'Select Background',
            icon: Icons.landscape,
            value: _selectedBackground,
            onChanged: (v) => setState(() => _selectedBackground = v),
          ),
      ],
    );
  }

  Widget _buildCharactersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Characters',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _useManualCharacter = !_useManualCharacter),
              icon: Icon(_useManualCharacter ? Icons.list : Icons.edit),
              label: Text(_useManualCharacter ? 'Predefined' : 'Manual'),
            ),
          ],
        ),
        if (_useManualCharacter)
          _buildTextField(
            controller: _manualCharacterController,
            label: 'Describe Characters',
            hint: 'e.g., A small robot and its pilot',
            icon: Icons.people,
            maxLines: 2,
          )
        else ...[
          _buildFirestoreDropdown(
            collection: 'characters',
            label: 'Add Character',
            icon: Icons.person_add,
            value: null,
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  final index = _selectedCharacters.indexWhere(
                    (c) => c['name'] == v,
                  );
                  if (index != -1) {
                    _selectedCharacters[index]['quantity']++;
                  } else {
                    _selectedCharacters.add({'name': v, 'quantity': 1});
                  }
                });
              }
            },
          ),
          if (_selectedCharacters.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._selectedCharacters.map((char) {
              return Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          char['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (char['quantity'] > 1) {
                              char['quantity']--;
                            } else {
                              _selectedCharacters.remove(char);
                            }
                          });
                        },
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        color: Colors.red[400],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${char['quantity']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            char['quantity']++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        color: Colors.green[400],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ],
    );
  }

  Widget _buildPromptResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'AI-Optimized Video Prompt (Editable):',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _promptController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Review and edit your video prompt here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppTheme.primaryColor.withOpacity(0.05),
          ),
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Navigate to generation status page
            Navigator.pushNamed(
              context,
              '/video-builder',
              arguments: {
                'prompt': _promptController.text,
                'title': _titleController.text,
                'background': _useManualBackground
                    ? _manualBackgroundController.text
                    : (_selectedBackground ?? ''),
                'characters': _useManualCharacter
                    ? _manualCharacterController.text
                    : _selectedCharacters
                          .map((c) => "${c['name']} (${c['quantity']})")
                          .join(", "),
                'duration': _duration.round(),
                'ratio': _selectedRatio,
                'seed': DateTime.now().millisecondsSinceEpoch % 1000000000,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
    final durations = [5, 8, 10];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Duration',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: durations.map((d) {
            final isSelected = _duration.round() == d;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text('${d}s'),
                selected: isSelected,
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _duration = d.toDouble());
                  }
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _createDirectly() {
    if (!_formKey.currentState!.validate()) return;

    String bg = _useManualBackground
        ? _manualBackgroundController.text
        : (_selectedBackground ?? '');
    String charInfo = "";
    if (_useManualCharacter) {
      charInfo = _manualCharacterController.text;
    } else {
      if (_selectedCharacters.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one character')),
        );
        return;
      }
      charInfo = _selectedCharacters
          .map((c) => "${c['name']} (${c['quantity']})")
          .join(", ");
    }

    if (bg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify a background')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/video-builder',
      arguments: {
        'prompt': _textController.text, // Use raw text as prompt
        'title': _titleController.text,
        'background': bg,
        'characters': charInfo,
        'duration': _duration.round(),
        'ratio': _selectedRatio,
        'seed': DateTime.now().millisecondsSinceEpoch % 1000000000,
      },
    );
  }

  Widget _buildRatioSelector() {
    final ratios = [
      {'label': '16:9 (Landscape)', 'value': '1280:720'},
      {'label': '9:16 (Portrait)', 'value': '720:1280'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aspect Ratio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRatio,
          onChanged: (v) => setState(() => _selectedRatio = v!),
          items: ratios.map((r) {
            return DropdownMenuItem(
              value: r['value'],
              child: Text(r['label']!),
            );
          }).toList(),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.aspect_ratio,
              color: AppTheme.primaryColor,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}
