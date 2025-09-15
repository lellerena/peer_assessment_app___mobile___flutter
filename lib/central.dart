import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/auth/ui/controller/auth_controller.dart';
import 'features/auth/ui/pages/login_screen.dart';
import 'features/courses/ui/pages/courses_page.dart';

class Central extends StatelessWidget {
  const Central({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationController authController = Get.find();
    return Obx(
      () => authController.isLogged ? const CoursesPage() : const LoginPage(),
    );
  }
}
