import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_service.dart';
import '../utils/app_theme.dart';

class CategoryInputPage extends StatefulWidget {
  final String categoryKey;
  final String categoryName;

  const CategoryInputPage({
    super.key,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  State<CategoryInputPage> createState() => _CategoryInputPageState();
}

class _CategoryInputPageState extends State<CategoryInputPage> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _aiService = AIService();
  final _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isGenerating = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) => print('Speech Error: $e'),
      onStatus: (s) => print('Speech Status: $s'),
    );
    if (mounted) setState(() {});
  }

  void _listen() async {
    if (!_speechAvailable) return;

    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _descriptionCtrl.text = val.recognizedWords;
              // Append or replace? For now replace to keep simple, or append if user pauses.
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _generateScript() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    // If description is empty, use AI to generate from title/simple prompt
    // If description is partially filled, use AI to refine it.

    setState(() => _isGenerating = true);
    FocusScope.of(context).unfocus();

    try {
      String input = _descriptionCtrl.text.isEmpty
          ? _titleCtrl.text
          : _descriptionCtrl.text;
      String script = await _aiService.generateVideoScript(
        input,
        widget.categoryName,
      );

      setState(() {
        _descriptionCtrl.text = script;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Script generated! Review it below.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _onNext() {
    if (_descriptionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or generate a description')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/character-background',
      arguments: {
        'category': widget.categoryKey,
        'title': _titleCtrl.text,
        'script': _descriptionCtrl.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'category_${widget.categoryName}',
              child: Card(
                color: AppTheme.primaryColor.withOpacity(0.1),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Provide details for your ${widget.categoryName} video. Use AI to expand your ideas!',
                          style: const TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Video Title',
                hintText: 'e.g. The Lost City',
              ),
            ),
            const SizedBox(height: 16),

            Stack(
              children: [
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Video Description / Script',
                    hintText: 'Describe the scene, dialogue, and atmosphere...',
                    alignLabelWithHint: true,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: FloatingActionButton.small(
                    heroTag: 'voice_btn',
                    backgroundColor: _isListening
                        ? Colors.red
                        : AppTheme.primaryColor,
                    onPressed: _speechAvailable ? _listen : null,
                    child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isGenerating ? null : _generateScript,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('Generate Magic Script'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _onNext,
                child: const Text('Next: Choose Characters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
