import 'package:flutter/material.dart';

import '../../core/entities/course.dart';
import '../../core/entities/user.dart';

import '../../core/services/course_repository_provider.dart' as diCourse;
import '../../core/services/auth_repository_provider.dart' as diAuth;

import '../../core/usecases/course_usecases.dart';

class EnrolledUsersScreen extends StatefulWidget {
  final Course course;
  const EnrolledUsersScreen({super.key, required this.course});

  @override
  State<EnrolledUsersScreen> createState() => _EnrolledUsersScreenState();
}

class _EnrolledUsersScreenState extends State<EnrolledUsersScreen> {
  late final getEnrolled =
      GetEnrolledUsers(diCourse.courseRepository, diAuth.authRepository);
  late final enroll =
      EnrollUserInCourse(diCourse.courseRepository);

  final emailCtrl = TextEditingController();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    users = getEnrolled(widget.course.id);
    setState(() {});
  }

  void _enrollByEmail() {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) return;

    final u = diAuth.authRepository.findByEmail(email);
    if (u == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No existe un usuario con ese email')));
      return;
    }

    enroll(courseId: widget.course.id, userId: u.id);
    emailCtrl.clear();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscritos • ${widget.course.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Inscribir por email (demo)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Inscribir por email',
                      hintText: 'usuario@ejemplo.com',
                    ),
                    onSubmitted: (_) => _enrollByEmail(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _enrollByEmail,
                  child: const Text('Inscribir'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('Sin inscritos'))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, i) {
                        final u = users[i];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(u.name),
                          subtitle: Text(u.email),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
