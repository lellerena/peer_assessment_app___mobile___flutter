import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import 'add_course_page.dart';
import 'enrolled_students_page.dart';
import 'category_page.dart';
import 'course_detail_page.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../../../../../core/router/app_routes.dart';

class TeacherCoursesPage extends StatelessWidget {
  const TeacherCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    c.getTeacherCourses(); // Carga los cursos del profesor

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cursos (Profesor)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final AuthenticationController auth = Get.find();
              await auth.logOut();
              Get.offAllNamed(Routes.login);
            },
          ),
        ],
      ),
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
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(course.name),
                subtitle: Text(course.description ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.category),
                      onPressed: () => Get.to(() => CategoryPage(
                        courseId: course.id,
                        courseName: course.name,
                      )),
                      tooltip: 'Categorías',
                    ),
                    IconButton(
                      icon: const Icon(Icons.people),
                      onPressed: () => Get.to(() => EnrolledStudentsPage(course: course)),
                      tooltip: 'Estudiantes',
                    ),
                  ],
                ),
                onTap: () => Get.to(() => CourseDetailPage(courseId: course.id)),
              ),
            );
          },
        );
      }),
    );
  }
}
