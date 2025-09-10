// lib/core/router/app_pages.dart
import 'package:get/get.dart';

import '../../features/splash/ui/pages/splash_page.dart';
import '../../features/auth/ui/pages/login_screen.dart';
import '../../features/user_courses/ui/pages/user_courses_screen.dart';
import '../../features/courses/ui/pages/my_courses_page.dart';
import '../../features/courses/ui/pages/add_course_page.dart';

import '../../features/auth/ui/controller/auth_controller.dart';
import '../../features/user_courses/ui/controller/user_courses_controller.dart';
import '../../features/user_courses/domain/usecases/get_user_courses_usecase.dart';
import '../../features/courses/ui/controllers/course_controller.dart';
import '../../features/courses/domain/usecases/course_usecase.dart';
import '../../features/categories/ui/controller/category_controller.dart';
import '../../features/categories/domain/use_case/category_usecase.dart';
import '../../features/categories/ui/pages/category_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._(); // evita instancias

  static final pages = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
      binding: BindingsBuilder(() {
        
        if (!Get.isRegistered<AuthController>()) {
          Get.put(AuthController(Get.find()), permanent: true);
        }
      }),
    ),
    GetPage(
      name: Routes.userCourses,
      page: () => const UserCoursesPage(),
      transition: Transition.rightToLeft,
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<UserCoursesController>()) {
          Get.lazyPut<UserCoursesController>(() =>
            UserCoursesController(
              Get.find<GetUserCoursesUseCase>(),
              Get.find<AuthController>(),
            ),
          );
        }
      }),
    ),
    GetPage(
      name: Routes.myCourses,
      page: () => const MyCoursesPage(),
      transition: Transition.rightToLeft,
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CourseController>()) {
          Get.put(CourseController(Get.find<CourseUseCase>()), permanent: true);
        }
      }),
    ),
    GetPage(
      name: Routes.addCourse,
      page: () => const AddCoursePage(),
      transition: Transition.downToUp,
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CourseController>()) {
          Get.put(CourseController(Get.find<CourseUseCase>()), permanent: true);
        }
      }),
    ),GetPage(
      name: Routes.categories,
      page: () => const CategoryPage(),
      binding: BindingsBuilder(() {
        // Si ya inyectas CategoryUseCase/Controller en main.dart, puedes omitir esto
        if (!Get.isRegistered<CategoryController>()) {
          Get.lazyPut<CategoryController>(() => CategoryController(Get.find<CategoryUseCase>()));
        }
      }),
    ),
  ];
}
