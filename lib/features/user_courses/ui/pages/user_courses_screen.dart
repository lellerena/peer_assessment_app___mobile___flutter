import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_courses_controller.dart';

class UserCoursesPage extends StatefulWidget {
  const UserCoursesPage({super.key});

  @override
  State<UserCoursesPage> createState() => _UserCoursesPageState();
}

class _UserCoursesPageState extends State<UserCoursesPage> {
  late final UserCoursesController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<UserCoursesController>(); // <- DI, no Get.put aquí
    c.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Mis cursos')),
      body: Obx(() {
        if (c.loading.value) return const Center(child: CircularProgressIndicator());
        if (c.courses.isEmpty) return const Center(child: Text('Aún no estás inscrito en ningún curso.'));
        return ListView.separated(
          itemCount: c.courses.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final course = c.courses[i];
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
