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
            // Campo de código de invitación
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Ingresa código de invitación',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onSubmitted: (code) => _joinCourseWithCode(code),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showJoinCourseDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('Unirse'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                        return _CourseList(items: availableCourses, currentUserId: userId, tabType: 'available');
                      case 1: // Creados
                        return _CourseList(items: created, currentUserId: userId, tabType: 'created');
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
                        return _CourseList(items: enrolledCourses, currentUserId: userId, tabType: 'enrolled');
                      default:
                        return _CourseList(items: all, currentUserId: userId, tabType: 'all');
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

  void _joinCourseWithCode(String code) {
    if (code.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa un código de invitación',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Simular unirse al curso con el código
    Get.snackbar(
      'Código Ingresado',
      'Código: $code\n\nFuncionalidad en desarrollo - Por ahora es solo para pruebas',
      backgroundColor: Theme.of(context).primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  void _showJoinCourseDialog() {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unirse a Curso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa el código de invitación que te compartió el profesor:'),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'Ej: INV123456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.qr_code, color: Theme.of(context).primaryColor),
                ),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _joinCourseWithCode(codeController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Unirse'),
            ),
          ],
        );
      },
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
  final String? currentUserId;
  final String tabType; // 'available', 'created', 'enrolled'
  const _CourseList({required this.items, this.currentUserId, this.tabType = 'all'});

  bool _shouldShowEnterButton(Course course, String? currentUserId) {
    if (currentUserId == null) return false;
    
    switch (tabType) {
      case 'available':
        // En "Disponibles": solo mostrar "Enter" si ya está inscrito
        return course.studentIds.contains(currentUserId);
      case 'created':
        // En "Creados": siempre mostrar "Enter" porque es el profesor
        return course.teacherId == currentUserId;
      case 'enrolled':
        // En "Inscritos": siempre mostrar "Enter" porque ya está inscrito
        return true;
      default:
        // Por defecto: mostrar "Enter" si es profesor o está inscrito
        return course.teacherId == currentUserId || course.studentIds.contains(currentUserId);
    }
  }

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
              isCreatedByUser: _shouldShowEnterButton(course, currentUserId),
            ),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatefulWidget {
  final Course course;
  final bool isHighlighted;
  final bool isCreatedByUser;
  
  const _CourseCard({
    required this.course,
    this.isHighlighted = false,
    this.isCreatedByUser = false,
  });

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _isEnrolled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    final controller = Get.find<CourseController>();
    final isEnrolled = await controller.isUserEnrolled(widget.course.id);
    if (mounted) {
      setState(() {
        _isEnrolled = isEnrolled;
      });
    }
  }

  Future<void> _enrollInCourse() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<CourseController>();
      await controller.enroll(widget.course.id);
      
      if (mounted) {
        setState(() {
          _isEnrolled = true;
          _isLoading = false;
        });
        
        Get.snackbar(
          'Éxito',
          'Te has inscrito exitosamente en ${widget.course.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        Get.snackbar(
          'Error',
          'Error al inscribirse: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1), // Color morado claro del tema
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
        border: Border.all(
          color: widget.isHighlighted ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: widget.isHighlighted ? 3 : 1,
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
                  widget.course.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.course.description ?? 'Sin descripción',
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
                onPressed: _isLoading ? null : () {
                  if (widget.isCreatedByUser || _isEnrolled) {
                    // Si es creado por el usuario o está inscrito, ir al detalle del curso
                    Get.to(() => CourseDetailPage(courseId: widget.course.id));
                  } else {
                    // Si no está inscrito, inscribirse
                    _enrollInCourse();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        (widget.isCreatedByUser || _isEnrolled) ? 'Enter' : 'Inscribirse',
                        style: const TextStyle(
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

