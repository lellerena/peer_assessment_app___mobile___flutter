import 'package:flutter/material.dart';

// Providers (nuestro “switch” de almacenamiento)
import '../../core/services/course_repository_provider.dart' as diCourse;
import '../../core/services/auth_repository_provider.dart' as diAuth;
import 'enrolled_users_screen.dart'; // arriba del archivo
// Use cases
import '../../core/usecases/course_usecases.dart';
import '../../core/services/auth_repository_provider.dart' as diAuth;
import '../../core/usecases/auth_usecases.dart';
import '../auth/login_screen.dart';

// (Siguiente archivo que crearemos ahora)
import 'create_course_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late final listCourses = ListCourses(diCourse.courseRepository);

  Future<void> _goCreate() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateCourseScreen()));
    setState(() {}); // refresca la lista al volver
  }

  @override
  Widget build(BuildContext context) {
    final courses = listCourses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // cerrar sesión
              SignOut(diAuth.authRepository)();
              // volver al login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goCreate,
        child: const Icon(Icons.add),
      ),
      body: courses.isEmpty
          ? const Center(child: Text('Aún no hay cursos'))
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (_, i) {
                final c = courses[i];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EnrolledUsersScreen(course: c),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
