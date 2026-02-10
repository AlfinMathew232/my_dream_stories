import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SelectCategoryPage extends StatelessWidget {
  const SelectCategoryPage({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Marketing', 'icon': Icons.campaign, 'color': Colors.blue},
    {'name': 'Dream Story', 'icon': Icons.auto_awesome, 'color': Colors.purple},
    {'name': 'Teaching', 'icon': Icons.school, 'color': Colors.orange},
    {'name': 'Motivational', 'icon': Icons.fitness_center, 'color': Colors.red},
    {'name': 'Kids Story', 'icon': Icons.child_care, 'color': Colors.green},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'What kind of video do you want to create?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Hero(
                    tag: 'category_${cat['name']}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/category-input',
                            arguments: {
                              'categoryKey': (cat['name'] as String)
                                  .toLowerCase(),
                              'categoryName': cat['name'],
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: (cat['color'] as Color).withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (cat['color'] as Color).withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: (cat['color'] as Color).withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cat['icon'],
                                  size: 32,
                                  color: cat['color'],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                cat['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
