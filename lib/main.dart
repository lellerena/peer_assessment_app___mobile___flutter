import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'injection_container.dart' as di;

// Pantallas
import 'features/auth/ui/pages/login_screen.dart';
import 'features/splash/ui/pages/splash_page.dart';
import 'features/categories/ui/pages/category_page.dart';
import 'features/courses/ui/pages/courses_page.dart';

// Categories
import 'features/categories/data/datasources/i_remote_category_source.dart';
import 'features/categories/data/datasources/remote/remote_category_source.dart';
import 'features/categories/data/repositories/category_repository.dart';
import 'features/categories/domain/repositories/i_category_repository.dart';
import 'features/categories/domain/use_case/category_usecase.dart';
import 'features/categories/ui/controller/category_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // -------- Categories DI --------
  Get.put<IRemoteCategorySource>(RemoteCategorySource(), permanent: true);
  Get.put<ICategoryRepository>(
    CategoryRepository(Get.find<IRemoteCategorySource>()),
    permanent: true,
  );
  Get.put<CategoryUseCase>(
    CategoryUseCase(Get.find<ICategoryRepository>()),
    permanent: true,
  );
  Get.put<CategoryController>(
    CategoryController(Get.find<CategoryUseCase>()),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // usa GetMaterialApp si navegas con Get.*
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
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CoursesPage())),
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
