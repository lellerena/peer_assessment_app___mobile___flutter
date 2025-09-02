import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_courses_controller.dart';

class UserCoursesScreen extends StatelessWidget {
  const UserCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserCoursesController());

    return Scaffold(
      appBar: AppBar(title: const Text('Mis cursos')),
      body: Obx(() {
        final userCourses = controller.userCourses;

        if (userCourses.isEmpty) {
          return const Center(child: Text('No estás inscrito en ningún curso.'));
        }

        return ListView.builder(
          itemCount: userCourses.length,
          itemBuilder: (context, index) {
            final course = userCourses[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(course.name),
                subtitle: Text("ID: ${course.id}"),
                onTap: () {
                  final enrolled = controller.getUsersFromIds(course.enrolledUserIds);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Usuarios inscritos"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: enrolled
                            .map((u) => ListTile(
                                  title: Text(u.name),
                                  subtitle: Text(u.id),
                                ))
                            .toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
