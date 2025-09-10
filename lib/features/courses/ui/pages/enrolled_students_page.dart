import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peer_assessment_app___mobile___flutter/features/auth/domain/models/user.dart';
import 'package:peer_assessment_app___mobile___flutter/features/auth/ui/controller/auth_controller.dart';
import 'package:peer_assessment_app___mobile___flutter/features/courses/domain/models/course.dart';

class EnrolledStudentsPage extends StatelessWidget {
  final Course course;

  const EnrolledStudentsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: Text('Estudiantes en ${course.name}')),
      body: FutureBuilder<List<User>>(
        future: authController.getUsersByIds(course.studentIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay estudiantes inscritos.'));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text(student.email),
              );
            },
          );
        },
      ),
    );
  }
}
