import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';

class EnrolledUsersPage extends StatefulWidget {
  final String courseId;
  const EnrolledUsersPage({super.key, required this.courseId});

  @override
  State<EnrolledUsersPage> createState() => _EnrolledUsersPageState();
}

class _EnrolledUsersPageState extends State<EnrolledUsersPage> {
  final c = Get.find<CourseController>();

  @override
  void initState() {
    super.initState();
    c.loadEnrolled(widget.courseId); // ← pide los IDs inscritos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios inscritos (IDs)')),
      body: Obx(() {
        final ids = c.enrolledUserIds;
        if (ids.isEmpty) return const Center(child: Text('Sin inscritos'));
        return ListView.builder(
          itemCount: ids.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(ids[i]),
          ),
        );
      }),
    );
  }
}
