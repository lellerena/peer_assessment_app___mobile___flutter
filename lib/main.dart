import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'injection_container.dart' as di;

// Pantallas
import 'features/auth/ui/pages/login_screen.dart';
import 'features/user_courses/ui/pages/user_courses_screen.dart';
import 'features/splash/ui/pages/splash_page.dart';
import 'features/categories/ui/pages/category_page.dart';

// Courses
import 'features/courses/ui/pages/list_course_page.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/domain/usecases/course_usecase.dart'; // asegúrate que la ruta es correcta
import 'features/courses/ui/controllers/course_controller.dart';
import 'features/user_courses/domain/usecases/get_user_courses_usecase.dart';
import 'features/user_courses/ui/controller/user_courses_controller.dart';

// Auth
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/usecase/auth_usecase.dart';
import 'features/auth/ui/controller/auth_controller.dart';

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

  // -------- Auth DI --------
  Get.put<AuthUseCase>(
    AuthUseCase(Get.find<IAuthRepository>()),
    permanent: true,
  );
  Get.put<AuthController>(
    AuthController(Get.find<AuthUseCase>()),
    permanent: true,
  );

  // -------- Courses DI --------
  Get.put<CourseRepository>(CourseRepository(), permanent: true);
  Get.put<CourseUseCase>(
    CourseUseCase(Get.find<CourseRepository>()),
    permanent: true,
  );
  Get.put<CourseController>(
    CourseController(Get.find<CourseUseCase>()),
    permanent: true,
  );

  // user_courses
  Get.put<GetUserCoursesUseCase>(
    GetUserCoursesUseCase(Get.find<CourseUseCase>()),
    permanent: true,
  );

  Get.put<UserCoursesController>(
    UserCoursesController(
      Get.find<GetUserCoursesUseCase>(),
      Get.find<AuthController>(),
    ),
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
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const UserCoursesPage())),
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
