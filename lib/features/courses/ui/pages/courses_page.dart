import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

        // Si no hay usuario autenticado, redirigir al login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.login);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _CoursesTabbed extends StatefulWidget {
  const _CoursesTabbed();

  @override
  State<_CoursesTabbed> createState() => _CoursesTabbedState();
}

class _CoursesTabbedState extends State<_CoursesTabbed> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    c.getAllCourses();
    c.getTeacherCourses();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con título y logout
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cursos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black),
                    onPressed: () async {
                      final AuthenticationController auth = Get.find();
                      await auth.logOut();
                      Get.offAllNamed(Routes.login);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tres botones separados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      text: 'Disponibles',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      text: 'Creados',
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      text: 'Inscritos',
                      isSelected: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Contenido
            Expanded(
              child: FutureBuilder<String?>(
                future: Get.find<ILocalPreferences>().retrieveData<String>('userId'),
                builder: (context, userIdSnapshot) {
                  if (!userIdSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final userId = userIdSnapshot.data;
                  
                  return Obx(() {
                    if (c.loading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = c.allCourses;
                    final created = c.teacherCourses;
                    
                    // Filtrar cursos inscritos y disponibles
                    final enrolledCourses = all.where((course) => 
                      course.studentIds.contains(userId)).toList();
                    final availableCourses = all.where((course) => 
                      !course.studentIds.contains(userId)).toList();
                    
                    switch (_selectedTab) {
                      case 0: // Disponibles
                        if (availableCourses.isEmpty) {
                          return const Center(
                            child: Text(
                              'No hay cursos disponibles para inscribirse.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return _CourseList(items: availableCourses);
                      case 1: // Creados
                        return _CourseList(items: created);
                      case 2: // Inscritos
                        if (enrolledCourses.isEmpty) {
                          return const Center(
                            child: Text(
                              'No estás inscrito en ningún curso.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return _CourseList(items: enrolledCourses);
                      default:
                        return _CourseList(items: all);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () => Get.to(() => const AddCoursePage()),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.home,
                      size: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
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
      return const Center(
        child: Text(
          'No hay cursos para mostrar.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final course = items[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _CourseCard(
              course: course,
              isHighlighted: i == 0,
            ),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final bool isHighlighted;
  
  const _CourseCard({
    required this.course,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1), // Color morado claro del tema
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
        border: Border.all(
          color: isHighlighted ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isHighlighted ? 3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  course.description ?? 'Sin descripción',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.grey[300],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => CourseDetailPage(courseId: course.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Enter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

