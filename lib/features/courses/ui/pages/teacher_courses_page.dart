import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import 'add_course_page.dart';

class TeacherCoursesPage extends StatelessWidget {
  const TeacherCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    c.getTeacherCourses(); // Carga los cursos del profesor

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Cursos (Profesor)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddCoursePage()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.teacherCourses.isEmpty) {
          return const Center(child: Text('Aún no has creado ningún curso.'));
        }
        return ListView.builder(
          itemCount: c.teacherCourses.length,
          itemBuilder: (_, i) {
            final course = c.teacherCourses[i];
            return ListTile(
              title: Text(course.name),
              subtitle: Text(course.description ?? ''),
            );
          },
        );
      }),
    );
  }
}
