import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:peer_assessment_app___mobile___flutter/features/auth/login_screen.dart';
import 'features/user_courses/screens/user_courses_screen.dart';
import 'features/splash/ui/pages/splash_page.dart';
import 'features/categories/ui/pages/category_page.dart';
import 'features/courses/courses_screen.dart';

import 'features/categories/data/datasources/i_remote_category_source.dart';
import 'features/categories/data/datasources/remote/remote_category_source.dart';
import 'features/categories/data/repositories/category_repository.dart';
import 'features/categories/domain/repositories/i_category_repository.dart';
import 'features/categories/domain/use_case/category_usecase.dart';
import 'features/categories/ui/controller/category_controller.dart';
import 'features/categories/ui/pages/category_page.dart';

void main() {
  // Category
  Get.put<IRemoteCategorySource>(RemoteCategorySource());
  Get.put<ICategoryRepository>(CategoryRepository(Get.find()));
  Get.put(CategoryUseCase(Get.find()));
  Get.put(CategoryController(Get.find()));
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
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CategoryPage())),
          ),
        ],
      ),
    );
  }
}
