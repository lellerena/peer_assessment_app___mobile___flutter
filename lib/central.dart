import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/ui/controller/auth_controller.dart';
import 'features/auth/ui/pages/login_screen.dart';
import 'features/courses/ui/pages/courses_page.dart';
import 'features/courses/ui/controllers/course_controller.dart';
import 'features/courses/domain/usecases/course_usecase.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationController authController = Get.find();
    if (!Get.isRegistered<CourseController>()) {
      Get.lazyPut(() => CourseController(Get.find<CourseUseCase>()),
          fenix: true);
    }
    return Obx(
      () => authController.isLogged ? const CoursesPage() : const LoginPage(),
    );
  }
}
