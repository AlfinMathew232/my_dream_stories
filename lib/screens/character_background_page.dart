import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';

class CharacterBackgroundPage extends StatefulWidget {
  const CharacterBackgroundPage({super.key});

  @override
  State<CharacterBackgroundPage> createState() =>
      _CharacterBackgroundPageState();
}

class _CharacterBackgroundPageState extends State<CharacterBackgroundPage> {
  // Mock Data
  final List<String> characters = [
    'https://cdn-icons-png.flaticon.com/512/4140/4140048.png', // Boy
    'https://cdn-icons-png.flaticon.com/512/4140/4140037.png', // Girl
    'https://cdn-icons-png.flaticon.com/512/4140/4140047.png', // Man
    'https://cdn-icons-png.flaticon.com/512/4140/4140051.png', // Woman
  ];

  final List<String> backgrounds = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=300', // Nature
    'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=300', // City
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=300', // Ocean
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300', // Mountains
  ];

  int _selectedCharIndex = -1;
  int _selectedBgIndex = -1;
  Map<String, dynamic>? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  void _onNext() {
    if (_selectedCharIndex == -1 || _selectedBgIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a character and a background'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/video-builder',
      arguments: {
        ..._args ?? {},
        'characterId': _selectedCharIndex.toString(),
        'characterUrl': characters[_selectedCharIndex],
        'backgroundId': _selectedBgIndex.toString(),
        'backgroundUrl': backgrounds[_selectedBgIndex],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visuals')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Select Character'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: characters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _buildSelectableItem(
                          imageUrl: characters[index],
                          isSelected: _selectedCharIndex == index,
                          onTap: () =>
                              setState(() => _selectedCharIndex = index),
                          isCircle: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionTitle('Select Background'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                    itemCount: backgrounds.length,
                    itemBuilder: (context, index) {
                      return _buildSelectableItem(
                        imageUrl: backgrounds[index],
                        isSelected: _selectedBgIndex == index,
                        onTap: () => setState(() => _selectedBgIndex = index),
                        isCircle: false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onNext,
                child: const Text('Create Video'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSelectableItem({
    required String imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isCircle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCircle ? 100 : null,
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 3)
              : Border.all(color: Colors.transparent, width: 3),
          borderRadius: BorderRadius.circular(isCircle ? 60 : 12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCircle ? 60 : 9),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
