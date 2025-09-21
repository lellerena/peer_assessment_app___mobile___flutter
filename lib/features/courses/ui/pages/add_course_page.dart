import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CourseController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear curso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Usamos un categoryId de ejemplo. Idealmente, aquí habría un selector.
                await c.addCourse(nameCtrl.text.trim(), descCtrl.text.trim());
                if (mounted) Get.back();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
