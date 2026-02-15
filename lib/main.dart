import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Services & Utils
import 'services/auth_service.dart';
import 'utils/app_theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/select_category_page.dart';
import 'screens/video_builder_page.dart';
import 'screens/my_videos_page.dart';
import 'screens/settings_page.dart';
import 'screens/payment_page.dart';
import 'screens/create_story_screen.dart';
import 'screens/prompt_review_screen.dart';

// Admin Screens
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_manage_categories.dart';
import 'screens/admin/admin_manage_characters.dart';
import 'screens/admin/admin_manage_backgrounds.dart';
import 'screens/admin/admin_user_list.dart';
import 'screens/admin/admin_analysis_page.dart';
import 'screens/edit_profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Add other providers here (VideoProvider, etc.)
      ],
      child: MaterialApp(
        title: 'My Dream Stories',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home': (_) => const HomePage(),
          '/select-category': (_) => const SelectCategoryPage(),
          '/video-builder': (_) => const VideoBuilderPage(),
          '/my-videos': (_) => const MyVideosPage(),
          '/settings': (_) => const SettingsPage(),
          '/payment': (_) => const PaymentPage(),
          '/create-story': (_) => const CreateStoryScreen(),
          '/prompt-review': (_) => const PromptReviewScreen(),

          // Admin
          '/admin': (_) => const AdminDashboardPage(),
          '/admin/categories': (_) => const AdminManageCategoriesPage(),
          '/admin/characters': (_) => const AdminManageCharactersPage(),
          '/admin/backgrounds': (_) => const AdminManageBackgroundsPage(),
          '/admin/users': (_) => const AdminUserListPage(),
          '/admin/analysis': (_) => const AdminAnalysisPage(),
          '/edit-profile': (_) => const EditProfilePage(),
        },
      ),
    );
  }
}
