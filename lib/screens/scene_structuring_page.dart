import 'package:flutter/material.dart';

class SceneStructuringPage extends StatefulWidget {
  const SceneStructuringPage({super.key});

  @override
  State<SceneStructuringPage> createState() => _SceneStructuringPageState();
}

class _SceneStructuringPageState extends State<SceneStructuringPage> {
  late List<Map<String, dynamic>> scenes;
  late String categoryKey;
  late String categoryName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    categoryKey = (args['categoryKey'] ?? '').toString();
    categoryName = (args['categoryName'] ?? '').toString();
    final raw = (args['scenes'] as List?) ?? [];
    scenes = raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    // Ensure text and duration fields exist
    for (final s in scenes) {
      s['text'] = s['text'] ?? '';
      s['duration'] = (s['duration'] ?? 4.0) as double; // seconds
    }
  }

  void _autoGenerate() {
    // Simple rule-based generator for demo: fill each scene with a template line
    setState(() {
      for (var i = 0; i < scenes.length; i++) {
        final s = scenes[i];
        s['text'] = s['text']?.toString().isNotEmpty == true
            ? s['text']
            : 'Scene ${i + 1}: ${categoryName} - describe action here...';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scene Structuring')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Category: $categoryName', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: scenes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = scenes[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Scene ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Character: ${s['character'] ?? 'Not selected'}'),
                            Text('Background: ${s['background'] ?? 'Not selected'}'),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: s['text']?.toString() ?? '',
                              maxLines: 3,
                              decoration: const InputDecoration(labelText: 'Scene text / narration'),
                              onChanged: (v) => s['text'] = v,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Duration (s): '),
                                Expanded(
                                  child: Slider(
                                    min: 2,
                                    max: 12,
                                    divisions: 10,
                                    value: (s['duration'] as double?) ?? 4.0,
                                    onChanged: (v) => setState(() => s['duration'] = v),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    ((s['duration'] as double?) ?? 4.0).toStringAsFixed(0),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Auto Generate Scenes'),
                    onPressed: _autoGenerate,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.navigate_next),
                    label: const Text('Next → Video Generation'),
                    onPressed: () {
                      final payload = {
                        'categoryKey': categoryKey,
                        'categoryName': categoryName,
                        'scenes': scenes,
                      };
                      Navigator.of(context).pushNamed('/video-builder', arguments: payload);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
