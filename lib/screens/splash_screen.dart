import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for branding
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, check role/profile if needed to route to Admin
      final dbService = DatabaseService();
      final userModel = await dbService.getUser(user.uid);

      if (!mounted) return;

      // Check Subscription Expiry
      if (userModel != null &&
          userModel.isPro &&
          userModel.subscriptionExpiry != null) {
        if (DateTime.now().isAfter(userModel.subscriptionExpiry!)) {
          // Subscription Expired - Downgrade User
          await dbService.updateUserProfile(user.uid, {
            'isPro': false,
            'subscriptionExpiry': null,
            'subscriptionStartDate': null,
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Your Pro subscription has expired. You have been downgraded to the free plan.',
                ),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      }

      if (userModel?.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Logo
            Icon(Icons.movie_filter, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'My Dream Stories',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
