import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../controllers/course_controller.dart';
import '../controllers/category_controller.dart';
import '../../domain/models/category.dart';
import '../../domain/usecases/category_usecase.dart';
import '../widgets/add_edit_category_dialog.dart';
import '../widgets/category_list_tile.dart';
import '../../../../core/i_local_preferences.dart';
import 'enrolled_students_page.dart';

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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final courses = snapshot.data![0] as List<Course>;
        final rawUser = snapshot.data![1] as String?;
        final course = courses.firstWhere((e) => e.id == courseId);
        bool isTeacher = false;
        if (rawUser != null) {
          // el rol se muestra sólo para navegación condicional (teacher/student)
          isTeacher = rawUser.contains('teacher');
          print('DEBUG: rawUser = $rawUser, isTeacher = $isTeacher');
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
  int _selected = 0; // 0: Info, 1: Categorías, 2: Actividades, 3: Grupos

  @override
  void initState() {
    super.initState();
    // Preparar el CategoryController como lo hace CategoryPage, pero embebido
    final String tag = 'category_controller_${widget.course.id}';
    if (!Get.isRegistered<CategoryController>(tag: tag)) {
      Get.put(
        CategoryController(Get.find<CategoryUseCase>(), widget.course.id),
        tag: tag,
      );
    }
  }

  @override
  void dispose() {
    final String tag = 'category_controller_${widget.course.id}';
    if (Get.isRegistered<CategoryController>(tag: tag)) {
      Get.delete<CategoryController>(tag: tag);
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _ChipButton(text: 'Info', selected: _selected == 0, onTap: () => setState(() => _selected = 0)),
                const SizedBox(width: 8),
                _ChipButton(text: 'Categorías', selected: _selected == 1, onTap: () => setState(() => _selected = 1)),
                const SizedBox(width: 8),
                _ChipButton(text: 'Actividades', selected: _selected == 2, onTap: () => setState(() => _selected = 2)),
                const SizedBox(width: 8),
                _ChipButton(text: 'Grupos', selected: _selected == 3, onTap: () => setState(() => _selected = 3)),
                const SizedBox(width: 8),
                if (isTeacher)
                  _ChipButton(
                    text: 'Agregar',
                    onTap: () {
                      setState(() => _selected = 1); // Ir a pestaña Categorías
                      final String tagNow = 'category_controller_${course.id}';
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final controller = Get.find<CategoryController>(tag: tagNow);
                        _showAddEditDialog(context, controller);
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                      _PurpleCard(
                        child: Text(
                          course.description?.trim().isNotEmpty == true
                              ? (course.description ?? '')
                              : 'Sin descripción',
                          style: const TextStyle(color: Colors.black87, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Participantes
                      _PurpleCard(
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
                            ...course.studentIds.take(3).map((id) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                        child: Text(
                                          id.isNotEmpty ? id[0].toUpperCase() : '?',
                                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(id, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87)),
                                      ),
                                    ],
                                  ),
                                )),
                            if (course.studentIds.isEmpty)
                              const Text('Aún no hay estudiantes inscritos.', style: TextStyle(color: Colors.black54)),
                            const SizedBox(height: 12),
                            if (isTeacher)
                              ElevatedButton(
                                onPressed: () => Get.to(() => EnrolledStudentsPage(course: course)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Ver estudiantes'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Actividades
                      _PurpleCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Actividades',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No hay actividades disponibles en este momento.',
                              style: TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            if (isTeacher)
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implementar navegación a crear actividad
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Crear Actividad'),
                              ),
                          ],
                        ),
                      ),
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
                                  final controller = Get.find<CategoryController>(tag: tag);
                                  return Obx(() => Text(
                                    'Categorías (${controller.categories.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ));
                                },
                              ),
                            ),
                            IconButton(
                              tooltip: 'Recargar',
                              onPressed: () {
                                final controller = Get.find<CategoryController>(tag: tag);
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
                            final controller = Get.find<CategoryController>(tag: tag);
                            return Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(child: CircularProgressIndicator());
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
                                        onPressed: () => controller.getCategories(),
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
                                        style: TextStyle(color: scheme.secondary),
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
                                    onEdit: () => _showAddEditDialog(context, controller, category),
                                    onDelete: () => _showDeleteConfirmation(context, controller, category),
                                  );
                                },
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      final controller = Get.find<CategoryController>(tag: tag);
                      _showAddEditDialog(context, controller);
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),

                // Actividades (placeholder visual)
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Actividades', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 12),
                      _PurpleCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Actividad 1', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            Text('Descripción de la actividad. Texto de ejemplo para ocupar espacio.',
                                style: TextStyle(color: Colors.black87, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Grupos (placeholder visual)
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Grupos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 12),
                      _PurpleCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Grupo 1', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            Text('Descripción del grupo. Texto de ejemplo para ocupar espacio.',
                                style: TextStyle(color: Colors.black87, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
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
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}


