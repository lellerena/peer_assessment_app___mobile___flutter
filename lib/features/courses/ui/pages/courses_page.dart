import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/domain/models/user.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import 'student_courses_page.dart';
import 'teacher_courses_page.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Obx(() {
      final user = authController.currentUser.value;
      if (user == null) {
        // Esto no debería pasar si el usuario está logueado, pero es un buen fallback
        return const Scaffold(
          body: Center(
            child: Text('Error: No se pudo determinar el rol del usuario.'),
          ),
        );
      }

      if (user.role == UserRole.teacher) {
        return const TeacherCoursesPage();
      } else {
        return const StudentCoursesPage();
      }
    });
  }
}
