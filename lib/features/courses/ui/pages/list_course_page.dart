import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';
import '../../domain/usecases/course_usecase.dart';
import '../../data/repositories/course_repository.dart';
import 'add_course_page.dart';
import 'enrolled_users_page.dart';

class ListCoursePage extends StatelessWidget {
  const ListCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 👉 Si no está el controller (o sus deps), créalos en cascada
    final CourseController c = Get.isRegistered<CourseController>()
        ? Get.find<CourseController>()
        : Get.put(
            CourseController(
              Get.isRegistered<CourseUseCase>()
                  ? Get.find<CourseUseCase>()
                  : CourseUseCase(
                      Get.isRegistered<CourseRepository>()
                          ? Get.find<CourseRepository>()
                          : Get.put(CourseRepository(), permanent: true),
                    ),
            ),
            permanent: true,
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Cursos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddCoursePage()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (c.loading.value) return const Center(child: CircularProgressIndicator());
        if (c.courses.isEmpty) return const Center(child: Text('Aún no hay cursos'));
        return ListView.builder(
          itemCount: c.courses.length,
          itemBuilder: (_, i) {
            final course = c.courses[i];
            return ListTile(
              title: Text(course.name),
              subtitle: Text(course.description ?? ''),
              onTap: () => Get.to(() => EnrolledUsersPage(courseId: course.id)),
            );
          },
        );
      }),
    );
  }
}
