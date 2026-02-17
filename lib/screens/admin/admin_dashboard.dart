import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: DatabaseService().getDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats =
              snapshot.data ??
              {
                'totalUsers': 0,
                'proMembers': 0,
                'videosCreated': 0,
                'totalCategories': 0,
                'totalCharacters': 0,
                'totalBackgrounds': 0,
              };

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatCard(stats),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _AdminCard(
                        title: 'Manage Categories',
                        subtitle: '${stats['totalCategories']} Categories',
                        icon: Icons.category,
                        color: Colors.blue,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/categories'),
                      ),
                      _AdminCard(
                        title: 'Manage Characters',
                        subtitle: '${stats['totalCharacters']} Characters',
                        icon: Icons.people,
                        color: Colors.purple,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/characters'),
                      ),
                      _AdminCard(
                        title: 'Manage Backgrounds',
                        subtitle: '${stats['totalBackgrounds']} Backgrounds',
                        icon: Icons.image,
                        color: Colors.teal,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/backgrounds'),
                      ),
                      _AdminCard(
                        title: 'Users & Subscriptions',
                        subtitle: '${stats['totalUsers']} Users',
                        icon: Icons.supervised_user_circle,
                        color: Colors.orange,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/users'),
                      ),
                      _AdminCard(
                        title: 'Revenue Analysis',
                        // subtitle: 'View Details',
                        icon: Icons.analytics,
                        color: Colors.green,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/analysis'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Users', stats['totalUsers'].toString()),
            _buildStatItem('Pro Members', stats['proMembers'].toString()),
            _buildStatItem('Videos Created', stats['videosCreated'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
