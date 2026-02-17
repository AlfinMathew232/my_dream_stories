import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<UserModel?>(
              stream: DatabaseService().getUserStream(user.uid),
              builder: (context, snapshot) {
                final userModel = snapshot.data;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildProfileCard(context, userModel),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Account'),
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.pushNamed(context, '/edit-profile');
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      onTap: () {
                        Navigator.pushNamed(context, '/privacy-security');
                      },
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Subscription'),
                    _buildSettingItem(
                      icon: Icons.star_border,
                      title: 'Current Plan',
                      subtitle: (userModel?.isPro ?? false)
                          ? 'Pro Member'
                          : 'Free User',
                      textColor: (userModel?.isPro ?? false)
                          ? Colors.orange
                          : null,
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await authService.logout();
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (_) => false);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: user?.profileImageUrl != null
                  ? CachedNetworkImageProvider(user!.profileImageUrl!)
                  : null,
              child: user?.profileImageUrl == null
                  ? Text(
                      user?.firstName.isNotEmpty == true
                          ? user!.firstName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppTheme.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
