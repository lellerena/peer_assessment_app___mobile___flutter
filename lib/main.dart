import 'package:flutter/material.dart';
import 'package:peer_assessment_app___mobile___flutter/features/auth/login_screen.dart';
import 'features/user_courses/screens/user_courses_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/categories/category_crud_screen.dart';
import 'features/courses/courses_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peer Assessment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peer Assessment App')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: const Icon(Icons.spa),
            title: const Text('Splash Screen'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SplashScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text('Courses'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserCoursesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories CRUD'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoryCrudScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
