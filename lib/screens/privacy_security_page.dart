import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoSection(
            title: 'Data Encryption',
            content:
                'Your data is encrypted using industry-standard AES-256 encryption. We prioritize your privacy and ensure that your personal information is secure.',
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'Privacy Policy',
            content:
                'We collect minimal data necessary to provide our services. We do not sell your personal information to third parties. For more details, please visit our website.',
            icon: Icons.privacy_tip_outlined,
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'Account Security',
            content:
                'We allow you to delete your account and all associated data at any time. If you suspect any unauthorized activity, please contact support immediately.',
            icon: Icons.security_outlined,
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            title: 'Third-Party Services',
            content:
                'We use trusted third-party services like Firebase for authentication and database management, and Razorpay for secure payments.',
            icon: Icons.cloud_queue,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
