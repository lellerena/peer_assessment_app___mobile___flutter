// features/courses/ui/pages/enrolled_users_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_assessment_app___mobile___flutter/features/courses/ui/controllers/course_controller.dart';

class EnrolledUsersPage extends StatefulWidget {
  final String courseId;
  final String? courseName;

  const EnrolledUsersPage({
    super.key,
    required this.courseId,
    this.courseName,
  });

  @override
  State<EnrolledUsersPage> createState() => _EnrolledUsersPageState();
}

class _EnrolledUsersPageState extends State<EnrolledUsersPage> {
  final c = Get.find<CourseController>();

  @override
  void initState() {
    super.initState();
    // Carga de inscritos para este curso
    c.loadEnrolled(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Inscritos • ${widget.courseName ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Crear categoría',
            onPressed: () => Get.toNamed('/categories'),
            icon: const Icon(Icons.category),
          ),
        ],
      ),
      body: Obx(() {
        final ids = c.enrolledUserIds; // o lo que uses
        if (ids.isEmpty) {
          return const Center(child: Text('Sin inscritos'));
        }
        return ListView.separated(
          itemCount: ids.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(ids[i]),
          ),
        );
      }),
    );
  }
}
