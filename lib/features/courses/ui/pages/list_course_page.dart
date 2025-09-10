import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../../ui/controllers/course_controller.dart';
import '../../../../core/router/app_routes.dart';

class ListCoursePage extends StatefulWidget {
  const ListCoursePage({super.key});

  @override
  State<ListCoursePage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<ListCoursePage> {
  late final CourseController c;

  @override
  void initState() {
    super.initState();
    c = Get.find<CourseController>();
    // Asegúrate de que tu controlador cargue/filtre mis cursos por createdByUserId
    // Si tu controlador ya lo hace en onInit, puedes omitir:
    // c.loadAll(); // y que exponga c.myCourses como RxList<Course>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Cursos'),
        actions: [
          // 👉 Botón que lleva al CRUD de categorías
          IconButton(
            tooltip: 'Crear categoría',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Get.toNamed(Routes.categories),
          ),
        ],
      ),
      body: Obx(() {
        // Usa la lista de cursos creados por el usuario (ajusta el nombre si difiere)
        final list = c.myCourses; // RxList<Course> filtrada por createdByUserId

        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (list.isEmpty) {
          return const Center(child: Text('Aún no has creado cursos.'));
        }

        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final course = list[i];
            return ListTile(
              title: Text(course.name),
              subtitle: Text(course.description ?? ''),
              trailing: IconButton(
                tooltip: 'Inscribir por email',
                icon: const Icon(Icons.person_add_alt_1),
                // 👉 Navega a la pantalla de inscritos (allí tienes el campo de email)
                onPressed: () => Get.toNamed(
                  Routes.enrolledUsers,
                  arguments: {'courseId': course.id, 'courseName': course.name},
                ),
              ),
              // Tap a ver inscritos / detalles
              onTap: () => Get.toNamed(
                Routes.enrolledUsers,
                arguments: {'courseId': course.id, 'courseName': course.name},
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Crear curso'),
        onPressed: () => Get.toNamed(Routes.addCourse),
      ),
    );
  }
}
