import 'package:flutter/material.dart';
import 'features/user_courses/screens/user_courses_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/categories/category_crud_screen.dart';

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
      home: const CategoryCrudScreen(),
    );
  }
}
