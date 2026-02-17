import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    if (user == null) {
      // Should handle nav to login, but just in case
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user.uid),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _HomeCard(
                        title: 'Create Video',
                        subtitle: 'AI Magic',
                        icon: Icons.movie_filter_outlined,
                        color: AppTheme.primaryColor,
                        onTap: () =>
                            Navigator.pushNamed(context, '/select-category'),
                      ),
                      _HomeCard(
                        title: 'My Videos',
                        subtitle: 'Your Gallery',
                        icon: Icons.video_library_outlined,
                        color: AppTheme.secondaryColor,
                        onTap: () => Navigator.pushNamed(context, '/my-videos'),
                      ),
                      _HomeCard(
                        title: 'Upgrade to Pro',
                        subtitle: 'Unlock Limits',
                        icon: Icons.diamond_outlined,
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/payment'),
                      ),
                      _HomeCard(
                        title: 'Settings',
                        subtitle: 'Profile & More',
                        icon: Icons.settings_outlined,
                        color: Colors.grey,
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String uid) {
    return StreamBuilder<UserModel?>(
      stream: DatabaseService().getUserStream(uid),
      builder: (context, snapshot) {
        final userModel = snapshot.data;
        final name = userModel?.firstName ?? 'Creator';
        final isPro = userModel?.isPro ?? false;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $name',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPro
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPro ? 'PRO MEMBER' : 'FREE PLAN',
                          style: TextStyle(
                            color: isPro
                                ? Colors.orange[800]
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: userModel?.profileImageUrl != null
                    ? CachedNetworkImageProvider(userModel!.profileImageUrl!)
                    : null,
                child: userModel?.profileImageUrl == null
                    ? const Icon(Icons.person, color: AppTheme.primaryColor)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
