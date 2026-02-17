import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import 'admin_generic_details_page.dart';

class AdminManageCategoriesPage extends StatefulWidget {
  const AdminManageCategoriesPage({super.key});

  @override
  State<AdminManageCategoriesPage> createState() =>
      _AdminManageCategoriesPageState();
}

class _AdminManageCategoriesPageState extends State<AdminManageCategoriesPage> {
  final _db = DatabaseService();

  void _showAddEditDialog({DocumentSnapshot? doc}) {
    final nameCtrl = TextEditingController(text: doc?['name']);
    final descCtrl = TextEditingController(text: doc?['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
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

              if (doc == null) {
                // Add
                await _db.createCategory(
                  nameCtrl.text.trim(),
                  descCtrl.text.trim(),
                );
              } else {
                // Update
                await doc.reference.update({
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                });
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
      appBar: AppBar(title: const Text('Manage Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminGenericDetailsPage(
                          collectionName: 'categories',
                          title: 'Edit Category',
                          docId: docs[index].id,
                          initialData: data,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      data['name'][0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(data['name']),
                  subtitle: Text(
                    data['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
