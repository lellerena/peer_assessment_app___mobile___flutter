import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../controllers/course_controller.dart';
import '../../../../core/i_local_preferences.dart';
import 'enrolled_students_page.dart';
import 'category_page.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    final ILocalPreferences prefs = Get.find();
    return FutureBuilder(
      future: Future.wait([
        c.usecase.getAll(),
        prefs.retrieveData<String>('user'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final courses = snapshot.data![0] as List<Course>;
        final rawUser = snapshot.data![1] as String?;
        final course = courses.firstWhere((e) => e.id == courseId);
        bool isTeacher = false;
        if (rawUser != null) {
          // el rol se muestra sólo para navegación condicional (teacher/student)
          isTeacher = rawUser.contains('teacher');
        }

        return Scaffold(
          appBar: AppBar(title: Text(course.name)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.description ?? ''),
                const SizedBox(height: 16),
                Text('Profesor: ${course.teacherId}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.to(() => CategoryPage(
                        courseId: course.id,
                        courseName: course.name,
                      )),
                      child: const Text('Categorías'),
                    ),
                    const SizedBox(width: 8),
                    if (isTeacher)
                      ElevatedButton(
                        onPressed: () => Get.to(() => EnrolledStudentsPage(course: course)),
                        child: const Text('Estudiantes'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


