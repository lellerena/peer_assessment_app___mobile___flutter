import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../controllers/course_controller.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    final AuthController auth = Get.find<AuthController>();
    c.getAllCourses(); // Carga todos los cursos

    return Scaffold(
      appBar: AppBar(title: const Text('Cursos Disponibles (Estudiante)')),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.allCourses.isEmpty) {
          return const Center(child: Text('No hay cursos disponibles en este momento.'));
        }
        return ListView.builder(
          itemCount: c.allCourses.length,
          itemBuilder: (_, i) {
            final course = c.allCourses[i];
            final isEnrolled = course.studentIds.contains(auth.currentUser.value?.id);
            return ListTile(
              title: Text(course.name),
              subtitle: Text(course.description ?? ''),
              trailing: ElevatedButton(
                onPressed: isEnrolled ? null : () => c.enroll(course.id),
                child: Text(isEnrolled ? 'Inscrito' : 'Inscribirse'),
              ),
            );
          },
        );
      }),
    );
  }
}
