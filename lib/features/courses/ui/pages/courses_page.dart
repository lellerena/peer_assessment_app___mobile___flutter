import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';

import '../../../auth/domain/models/user_public.dart';
import '../../../auth/domain/models/user_role.dart';
import 'student_courses_page.dart';
import 'teacher_courses_page.dart';
import '../../../../../core/i_local_preferences.dart';
import '../controllers/course_controller.dart';
import '../../domain/models/course.dart';
import 'course_detail_page.dart';
import 'add_course_page.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../../../../../core/router/app_routes.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ILocalPreferences sharedPreferences = Get.find();

    return FutureBuilder(
      future: Future.wait([
        sharedPreferences.retrieveData<String>('user'),
        sharedPreferences.retrieveData<String>('userId'),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final raw = snapshot.data?[0];
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (raw != null && raw.isNotEmpty) {
          return const _CoursesTabbed();
        }

        // Fallback: si no hay user serializado, pero sí userId, mostramos tabs neutras
        return const _CoursesTabbed();
      },
    );
  }
}

class _CoursesTabbed extends StatelessWidget {
  const _CoursesTabbed();

  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    c.getAllCourses();
    c.getTeacherCourses();

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          return AnimatedBuilder(
            animation: controller,
            builder: (_, __) => Scaffold(
              appBar: AppBar(
                title: const Text('Cursos'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      final AuthenticationController auth = Get.find();
                      await auth.logOut();
                      Get.offAllNamed(Routes.login);
                    },
                  ),
                ],
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Disponibles'),
                    Tab(text: 'Creados'),
                    Tab(text: 'Inscritos'),
                  ],
                ),
              ),
              floatingActionButton: controller.index == 1
                  ? FloatingActionButton(
                      onPressed: () => Get.to(() => const AddCoursePage()),
                      child: const Icon(Icons.add),
                    )
                  : null,
              body: Obx(() {
                if (c.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = c.allCourses;
                final created = c.teacherCourses;
                return TabBarView(
                  children: [
                    _CourseList(items: all),
                    _CourseList(items: created),
                    _EnrolledList(),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _CourseList extends StatelessWidget {
  final List<Course> items;
  const _CourseList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay cursos para mostrar.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final course = items[i];
        return ListTile(
          title: Text(course.name),
          subtitle: Text(course.description ?? ''),
          onTap: () => Get.to(() => CourseDetailPage(courseId: course.id)),
        );
      },
    );
  }
}

class _EnrolledList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    final ILocalPreferences prefs = Get.find();
    return FutureBuilder<String?>(
      future: prefs.retrieveData<String>('userId'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userId = snapshot.data!;
        final enrolled = c.allCourses
            .where((e) => e.studentIds.contains(userId))
            .toList();
        if (enrolled.isEmpty) {
          return const Center(child: Text('No hay cursos para mostrar.'));
        }
        return ListView.builder(
          itemCount: enrolled.length,
          itemBuilder: (_, i) {
            final course = enrolled[i];
            return ListTile(
              title: Text(course.name),
              subtitle: Text(course.description ?? ''),
              onTap: () => Get.to(() => CourseDetailPage(courseId: course.id)),
            );
          },
        );
      },
    );
  }
}
