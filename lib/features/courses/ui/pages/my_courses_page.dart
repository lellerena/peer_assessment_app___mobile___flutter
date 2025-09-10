import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_assessment_app___mobile___flutter/core/router/app_routes.dart';
import 'package:peer_assessment_app___mobile___flutter/features/courses/ui/pages/enrolled_users_page.dart';
// Ajusta este import al controlador que ya usas para cursos
import '../../ui/controllers/course_controller.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  late final CourseController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<CourseController>();
    // Si tu controlador no carga solo, llama aquí:
    // c.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Mis cursos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.addCourse),
        icon: const Icon(Icons.add),
        label: const Text('Crear curso'),
      ),
      body: Obx(() {
        // Asegúrate que en tu CourseController existan estas propiedades:
        // - loading (RxBool)
        // - myCourses (RxList<Course>) filtrada por createdByUserId
        if (c.loading.value) return const Center(child: CircularProgressIndicator());
        if (c.myCourses.isEmpty) return const Center(child: Text('Aún no has creado cursos.'));
        return ListView.separated(
          itemCount: c.myCourses.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final course = c.myCourses[i];
            return ListTile(
                title: Text(course.name),
                subtitle: Text(course.description ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
  Get.to(() => EnrolledUsersPage(
    courseId: course.id,
    courseName: course.name,
  ));
},
);
          },
        );
      }),
    );
  }
}
