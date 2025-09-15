import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/domain/models/user.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import 'student_courses_page.dart';
import 'teacher_courses_page.dart';
import '../../../../../core/i_local_preferences.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ILocalPreferences sharedPreferences = Get.find();

    return FutureBuilder<User?>(
      future: sharedPreferences.retrieveData<User>('user'),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
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
      },
    );
  }
}
