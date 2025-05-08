import 'package:central_app_flutter/screens/ManagersListScreen.dart';
import 'package:central_app_flutter/screens/RegisterManagerScreen.dart';
import 'package:central_app_flutter/screens/school_status_screen.dart';
import 'package:central_app_flutter/screens/users_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/add_user_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/schools_list_screen.dart';
import 'screens/school_details_screen.dart';
import 'screens/add_school_screen.dart';
import 'services/theme_controller.dart'; // استيراد الكونترولر الجديد


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lhzujcquhgxhsmmjwgdq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoenVqY3F1aGd4aHNtbWp3Z2RxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4MjQ4NjQsImV4cCI6MjA2MTQwMDg2NH0.u7qPHRu_TdmNjPQJhMeXMZVI37xJs8IoX5Dcrg7fxV8',
  );
  runApp(const CentralApp());
}


class CentralApp extends StatelessWidget {
  const CentralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Central App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/schools': (context) => const SchoolsListScreen(),
            '/addSchool': (context) => const AddSchoolScreen(),
            '/add-school': (context) => const AddSchoolScreen(),
            '/add-manager': (context) => const AddUserScreen(),
            '/school-status': (context) => const SchoolStatusScreen(),
            '/users': (context) => const UsersManagementScreen()
          },
        );
      },
    );
  }
}