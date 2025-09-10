import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ===== Router (tus archivos nuevos) =====
import 'core/router/app_routes.dart';
import 'core/router/app_pages.dart';

// ===== Auth =====
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/usecase/auth_usecase.dart';
import 'features/auth/ui/controller/auth_controller.dart';

// ===== Courses =====
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/domain/usecases/course_usecase.dart';
import 'features/courses/ui/controllers/course_controller.dart';
import 'features/user_courses/domain/usecases/get_user_courses_usecase.dart';

// ===== Categories (opcional si las usas en esta app) =====
import 'features/categories/data/datasources/remote/remote_category_source.dart';
import 'features/categories/data/datasources/i_remote_category_source.dart';
import 'features/categories/data/repositories/category_repository.dart';
import 'features/categories/domain/repositories/i_category_repository.dart';
import 'features/categories/domain/use_case/category_usecase.dart';
import 'features/categories/ui/controller/category_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------- Categories DI ----------------
  Get.put<IRemoteCategorySource>(RemoteCategorySource());
  Get.put<ICategoryRepository>(CategoryRepository(Get.find()));
  Get.put(CategoryUseCase(Get.find()));
  Get.put(CategoryController(Get.find()));

  // ----------------  Auth DI  --------------------
  Get.put<AuthRepository>(AuthRepository(), permanent: true);
  Get.put<AuthUseCase>(AuthUseCase(Get.find<AuthRepository>()), permanent: true);
  Get.put<AuthController>(AuthController(Get.find<AuthUseCase>()), permanent: true);

  // ---------------- Courses DI -------------------
  Get.put<CourseRepository>(CourseRepository(), permanent: true);
  Get.put<CourseUseCase>(CourseUseCase(Get.find<CourseRepository>()), permanent: true);
  Get.put<CourseController>(CourseController(Get.find<CourseUseCase>()), permanent: true);

  Get.put<GetUserCoursesUseCase>(
  GetUserCoursesUseCase(Get.find<CourseUseCase>()), // o Get.find<ICourseRepository>() si tu ctor usa repo
  permanent: true,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peer Assessment App',
      initialRoute: Routes.splash,
      getPages: AppPages.pages, // <- usa tu AppPages
    );
  }
}
