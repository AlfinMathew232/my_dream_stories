import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class AdminUserListPage extends StatelessWidget {
  const AdminUserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users & Subscriptions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isPro = data['isPro'] ?? false;
              final name =
                  '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
              final email = data['email'] ?? 'No email';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(name.isNotEmpty ? name : 'Anonymous'),
                  subtitle: Text(email),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPro ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPro ? 'PRO' : 'NORMAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPro ? Colors.green[800] : Colors.grey[700],
                      ),
                    ),
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
