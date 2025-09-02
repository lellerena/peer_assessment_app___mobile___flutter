import 'package:flutter/material.dart';

// Providers
import '../../core/services/course_repository_provider.dart' as diCourse;
import '../../core/services/auth_repository_provider.dart' as diAuth;

// Use case
import '../../core/usecases/course_usecases.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  late final createCourse = CreateCourse(diCourse.courseRepository);

  void _save() {
    final currentUser = diAuth.authRepository.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    final name = nameCtrl.text.trim();
    final desc = descCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }

    createCourse(
      name: name,
      description: desc,
      createdByUserId: currentUser.id,
    );

    Navigator.of(context).pop(); // volver al listado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear curso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del curso'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
