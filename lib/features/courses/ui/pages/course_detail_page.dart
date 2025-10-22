import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../controllers/course_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/assessment_controller.dart';
import '../../domain/models/category.dart';
import '../../domain/usecases/category_usecase.dart';
import '../../domain/usecases/assessment_usecase.dart';
import '../../domain/usecases/activity_usecase.dart';
import '../widgets/add_edit_category_dialog.dart';
import '../widgets/category_list_tile.dart';
import '../../../../core/i_local_preferences.dart';
import 'enrolled_students_page.dart';
import 'all_participants_page.dart';
import 'activity_tab.dart';
import 'assessment_tab_simple.dart';
import 'reports_tab.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final CourseController c = Get.find<CourseController>();
    final ILocalPreferences prefs = Get.find();
    return FutureBuilder(
      future: Future.wait([
        c.usecase.getAll(),
        prefs.retrieveData<String>('user'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final courses = snapshot.data![0] as List<Course>;
        final rawUser = snapshot.data![1] as String?;
        final course = courses.firstWhere((e) => e.id == courseId);
        bool isTeacher = false;
        if (rawUser != null) {
          // Determinar si el usuario es profesor del curso específico
          // Un usuario es profesor si es el creador del curso (teacherId)
          final userData = json.decode(rawUser);
          final userId = userData['id'] as String?;
          isTeacher = userId != null && course.teacherId == userId;
          print(
            'DEBUG: rawUser = $rawUser, userId = $userId, course.teacherId = ${course.teacherId}, isTeacher = $isTeacher',
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              course.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: _CourseDetailTabbed(course: course, isTeacher: isTeacher),
        );
      },
    );
  }
}

class _CourseDetailTabbed extends StatefulWidget {
  final Course course;
  final bool isTeacher;
  const _CourseDetailTabbed({required this.course, required this.isTeacher});

  @override
  State<_CourseDetailTabbed> createState() => _CourseDetailTabbedState();
}

class _CourseDetailTabbedState extends State<_CourseDetailTabbed> {
  int _selected = 0; // 0: Info, 1: Categorías, 2: Actividades, 3: Evaluaciones, 4: Participantes

  @override
  void initState() {
    super.initState();
    // Preparar el CategoryController como lo hace CategoryPage, pero embebido
    final String categoryTag = 'category_controller_${widget.course.id}';
    if (!Get.isRegistered<CategoryController>(tag: categoryTag)) {
      Get.put(
        CategoryController(Get.find<CategoryUseCase>(), widget.course.id),
        tag: categoryTag,
      );
    }
    
    // Preparar el AssessmentController
    final String assessmentTag = 'assessment_controller_${widget.course.id}';
    if (!Get.isRegistered<AssessmentController>(tag: assessmentTag)) {
      Get.put(
        AssessmentController(Get.find<AssessmentUseCase>(), Get.find<CategoryUseCase>(), Get.find<ActivityUseCase>(), widget.course.id),
        tag: assessmentTag,
      );
    }
  }

  @override
  void dispose() {
    final String categoryTag = 'category_controller_${widget.course.id}';
    if (Get.isRegistered<CategoryController>(tag: categoryTag)) {
      Get.delete<CategoryController>(tag: categoryTag);
    }
    
    final String assessmentTag = 'assessment_controller_${widget.course.id}';
    if (Get.isRegistered<AssessmentController>(tag: assessmentTag)) {
      Get.delete<AssessmentController>(tag: assessmentTag);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Course course = widget.course;
    final bool isTeacher = widget.isTeacher;
    final String tag = 'category_controller_${course.id}';
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pestañas con scroll horizontal para móviles
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ChipButton(
                    text: 'Info',
                    selected: _selected == 0,
                    onTap: () => setState(() => _selected = 0),
                  ),
                  const SizedBox(width: 8),
                  _ChipButton(
                    text: 'Categorías',
                    selected: _selected == 1,
                    onTap: () => setState(() => _selected = 1),
                  ),
                  const SizedBox(width: 8),
                  _ChipButton(
                    text: 'Actividades',
                    selected: _selected == 2,
                    onTap: () => setState(() => _selected = 2),
                  ),
                  const SizedBox(width: 8),
                  _ChipButton(
                    text: 'Evaluaciones',
                    selected: _selected == 3,
                    onTap: () => setState(() => _selected = 3),
                  ),
                  const SizedBox(width: 8),
                  _ChipButton(
                    text: 'Participantes',
                    selected: _selected == 4,
                    onTap: () => setState(() => _selected = 4),
                  ),
                  const SizedBox(width: 8),
                  _ChipButton(
                    text: 'Reportes',
                    selected: _selected == 5,
                    onTap: () => setState(() => _selected = 5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _selected,
              children: [
                // Info
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información del curso
                      _PurpleCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Descripción del curso',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.description?.trim().isNotEmpty == true
                                  ? (course.description ?? '')
                                  : 'Sin descripción disponible',
                              style: const TextStyle(
                                color: Colors.black87,
                                height: 1.4,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Participantes
                      _ParticipantsCard(course: course, isTeacher: isTeacher),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Categorías (con FloatingActionButton igual que en cursos)
                Scaffold(
                  backgroundColor: Colors.white,
                  body: Column(
                    children: [
                      // Header con contador y botón de reload
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: GetBuilder<CategoryController>(
                                tag: tag,
                                builder: (_) {
                                  final controller =
                                      Get.find<CategoryController>(tag: tag);
                                  return Obx(
                                    () => Text(
                                      'Categorías (${controller.categories.length})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              tooltip: 'Recargar',
                              onPressed: () {
                                final controller = Get.find<CategoryController>(
                                  tag: tag,
                                );
                                controller.getCategories();
                              },
                              icon: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                      ),
                      // Contenido de categorías
                      Expanded(
                        child: GetBuilder<CategoryController>(
                          tag: tag,
                          initState: (_) {
                            final ctrl = Get.find<CategoryController>(tag: tag);
                            ctrl.getCategories();
                          },
                          builder: (_) {
                            final controller = Get.find<CategoryController>(
                              tag: tag,
                            );
                            return Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (controller.errorMessage.value.isNotEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 80,
                                        color: scheme.error,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Error',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: scheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        controller.errorMessage.value,
                                        style: TextStyle(color: scheme.error),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () =>
                                            controller.getCategories(),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (controller.categories.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        size: 80,
                                        color: scheme.secondary,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'No categories found.',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add a new category for this course using the button below.',
                                        style: TextStyle(
                                          color: scheme.secondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: controller.categories.length,
                                itemBuilder: (context, index) {
                                  final category = controller.categories[index];
                                  return CategoryListTile(
                                    category: category,
                                    onEdit: () => _showAddEditDialog(
                                      context,
                                      controller,
                                      category,
                                    ),
                                    onDelete: () => _showDeleteConfirmation(
                                      context,
                                      controller,
                                      category,
                                    ),
                                    isTeacher: isTeacher,
                                    course: course,
                                  );
                                },
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: isTeacher
                      ? FloatingActionButton(
                          heroTag: "category_fab_${widget.course.id}",
                          backgroundColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            final controller = Get.find<CategoryController>(
                              tag: tag,
                            );
                            _showAddEditDialog(context, controller);
                          },
                          child: const Icon(Icons.add, color: Colors.white),
                        )
                      : null,
                ),

                // Actividades
                ActivityTab(course: course, isTeacher: isTeacher),

                // Evaluaciones
                AssessmentTabSimple(course: course, isTeacher: isTeacher),

                // Participantes (todos los usuarios inscritos)
                _AllParticipantsTab(course: course, isTeacher: isTeacher),

                // Reportes (solo para profesores)
                isTeacher ? ReportsTab(course: course) : const Center(child: Text('Acceso restringido')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Métodos auxiliares para manejar diálogos de categorías
void _showAddEditDialog(
  BuildContext context,
  CategoryController controller, [
  Category? category,
]) {
  showDialog(
    context: context,
    builder: (context) => AddEditCategoryDialog(
      category: category,
      onSave: (newCategory) {
        if (category == null) {
          controller.addCategory(newCategory);
        } else {
          controller.updateCategory(newCategory);
        }
      },
    ),
  );
}

void _showDeleteConfirmation(
  BuildContext context,
  CategoryController controller,
  Category category,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
            onPressed: () {
              controller.deleteCategory(category);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class _ChipButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ChipButton({
    required this.text,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 60,
          minHeight: 36,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
          border: selected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _PurpleCard extends StatelessWidget {
  final Widget child;
  const _PurpleCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _ParticipantsCard extends StatefulWidget {
  final Course course;
  final bool isTeacher;

  const _ParticipantsCard({required this.course, required this.isTeacher});

  @override
  State<_ParticipantsCard> createState() => _ParticipantsCardState();
}

class _ParticipantsCardState extends State<_ParticipantsCard> {
  List<Map<String, String>> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      final controller = Get.find<CourseController>();
      final participants = await controller
          .getUsersByIds(widget.course.studentIds)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _participants = participants;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading participants: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PurpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Participantes',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_participants.isEmpty)
            Text(
              widget.course.studentIds.isEmpty
                  ? 'Aún no hay estudiantes inscritos.'
                  : 'Error al cargar participantes.',
              style: const TextStyle(color: Colors.black54),
            )
          else ...[
            // Mostrar máximo 4 participantes
            ..._participants
                .take(4)
                .map(
                  (userData) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                          child: Text(
                            userData['name']?.isNotEmpty == true
                                ? userData['name']![0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'Usuario',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                userData['email'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            // Si hay más de 4 participantes, mostrar botón para ver todos
            if (_participants.length > 4) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Get.to(
                    () => AllParticipantsPage(
                      course: widget.course,
                      participants: _participants,
                    ),
                  ),
                  child: Text(
                    'Ver todos los participantes (${_participants.length})',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            if (widget.isTeacher)
              ElevatedButton(
                onPressed: () =>
                    Get.to(() => EnrolledStudentsPage(course: widget.course)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Ver estudiantes'),
              ),
          ],
        ],
      ),
    );
  }
}

class _AllParticipantsTab extends StatefulWidget {
  final Course course;
  final bool isTeacher;

  const _AllParticipantsTab({required this.course, required this.isTeacher});

  @override
  State<_AllParticipantsTab> createState() => _AllParticipantsTabState();
}

class _AllParticipantsTabState extends State<_AllParticipantsTab> {
  List<Map<String, String>> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      final controller = Get.find<CourseController>();
      final participants = await controller
          .getUsersByIds(widget.course.studentIds)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _participants = participants;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading participants: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Participantes (${_participants.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              if (widget.isTeacher)
                ElevatedButton(
                  onPressed: () =>
                      Get.to(() => EnrolledStudentsPage(course: widget.course)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Gestionar'),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_participants.isEmpty)
            _PurpleCard(
              child: const Text(
                'Aún no hay estudiantes inscritos.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ..._participants.map(
              (userData) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _PurpleCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.2),
                        child: Text(
                          userData['name']?.isNotEmpty == true
                              ? userData['name']![0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'] ?? 'Usuario',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userData['email'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ESTUDIANTE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
