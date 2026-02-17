import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'admin_generic_details_page.dart';

class AdminManageBackgroundsPage extends StatefulWidget {
  const AdminManageBackgroundsPage({super.key});

  @override
  State<AdminManageBackgroundsPage> createState() =>
      _AdminManageBackgroundsPageState();
}

class _AdminManageBackgroundsPageState
    extends State<AdminManageBackgroundsPage> {
  void _showAddEditDialog({DocumentSnapshot? doc}) {
    final nameCtrl = TextEditingController(text: doc?['name']);
    final descriptionCtrl = TextEditingController(text: doc?['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? 'Add Background' : 'Edit Background'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (Prompt)',
                hintText: 'Describe the background for AI generation',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: Describe the background scene you want to generate.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;

              final data = {
                'name': nameCtrl.text.trim(),
                'description': descriptionCtrl.text.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              };

              if (doc == null) {
                await FirebaseFirestore.instance
                    .collection('backgrounds')
                    .add(data);
              } else {
                await doc.reference.update(data);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Backgrounds')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('backgrounds')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No backgrounds found.'));

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminGenericDetailsPage(
                        collectionName: 'backgrounds',
                        title: 'Edit Background',
                        docId: docs[index].id,
                        initialData: data,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              data['description'] ?? 'No description',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              data['name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to edit',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
