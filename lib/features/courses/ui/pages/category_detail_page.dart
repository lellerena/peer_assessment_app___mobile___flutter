import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';
import '../../domain/usecases/category_usecase.dart';
import '../controllers/category_controller.dart';
import '../../domain/models/course.dart';
import '../controllers/course_controller.dart';
import '../widgets/add_edit_category_dialog.dart';
import '../../../../core/i_local_preferences.dart';

class CategoryDetailPage extends StatelessWidget {
  final Category category;
  final Course course;
  final bool isTeacher;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.course,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _CategoryDetailContent(
          category: category,
          course: course,
          isTeacher: isTeacher,
        ),
      ),
    );
  }
}

class _CategoryDetailContent extends StatefulWidget {
  final Category category;
  final Course course;
  final bool isTeacher;

  const _CategoryDetailContent({
    required this.category,
    required this.course,
    required this.isTeacher,
  });

  @override
  State<_CategoryDetailContent> createState() => _CategoryDetailContentState();
}

class _CategoryDetailContentState extends State<_CategoryDetailContent> {
  late CategoryController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final String tag = 'category_controller_${widget.course.id}';
    if (Get.isRegistered<CategoryController>(tag: tag)) {
      _controller = Get.find<CategoryController>(tag: tag);
    } else {
      final categoryUseCase = Get.find<CategoryUseCase>();
      _controller = Get.put(CategoryController(categoryUseCase, widget.course.id), tag: tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tag = 'category_controller_${widget.course.id}';
    return GetBuilder<CategoryController>(
      tag: tag,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            final categories = _controller.categories;
            final current = categories.firstWhere(
              (c) => c.id == widget.category.id,
              orElse: () => widget.category,
            );
            
            print("Building CategoryDetailPage for category: ${current.name} with ${current.groups.length} groups");
            if (_controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _controller.errorMessage.value,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _controller.getCategories(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final groups = current.groups;

            // userId se obtiene asincrónicamente más abajo (dentro del FutureBuilder)

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryInfoCard(
                  category: current,
                  isTeacher: widget.isTeacher,
                  onEdit: () => _showEditCategoryDialog(),
                  onDelete: () => _showDeleteConfirmation(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grupos (${groups.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.isTeacher)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (current.groupingMethod.name == 'random') ...[
                            OutlinedButton(
                              onPressed: () => _onRegenerateRandom(current),
                              child: const Text('Regenerar'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton(
                            onPressed: () => _showCreateGroupDialog(current),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Crear Grupo'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: groups.isEmpty
                      ? _EmptyGroupsState(isTeacher: widget.isTeacher)
                      : FutureBuilder<List<Map<String, String>>>(
                          future: Get.find<CourseController>()
                              .getUsersByIds(widget.course.studentIds),
                          builder: (context, snapshot) {
                            final Map<String, Map<String, String>> userMap = {
                              for (final u in (snapshot.data ?? const []))
                                if (u['id'] != null) u['id']!: u
                            };

                            return FutureBuilder<String?>(
                              future: Get.find<ILocalPreferences>().retrieveData<String>('userId'),
                              builder: (context, uidSnap) {
                                final String? currentUserId = uidSnap.data;
                                final bool userAlreadyAssigned = currentUserId == null
                                    ? false
                                    : current.groups.any((g) => g.studentIds.contains(currentUserId));

                                return _GroupsList(
                                  groups: groups,
                                  isTeacher: widget.isTeacher,
                                  category: current,
                                  currentUserId: currentUserId,
                                  userAlreadyAssigned: userAlreadyAssigned,
                                  onEditGroup: (group) => _showEditGroupDialog(current, group),
                                  onDeleteGroup: (group) => _showDeleteGroupConfirmation(current, group),
                                  onAddStudent: (group) => _onAddStudent(current, group),
                                  onRemoveStudent: (group, studentId) => _onRemoveStudent(current, group, studentId),
                                  userMap: userMap,
                                  onJoinGroup: (group) async {
                                    if (currentUserId == null) {
                                      Get.snackbar(
                                        'Sesión requerida',
                                        'Inicia sesión para unirte a un grupo.',
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                        colorText: Theme.of(context).colorScheme.onError,
                                      );
                                      return;
                                    }
                                    await _controller.enrollStudentToGroup(current.id, group.id, currentUserId);
                                    if (!mounted) return;
                                    Get.snackbar(
                                      'Listo',
                                      'Te uniste a ${group.name}.',
                                      backgroundColor: Theme.of(context).primaryColor,
                                      colorText: Theme.of(context).colorScheme.onPrimary,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  void _showEditCategoryDialog() {
    final current = _controller.categories.firstWhere(
      (c) => c.id == widget.category.id,
      orElse: () => widget.category,
    );

    showDialog(
      context: context,
      builder: (_) => AddEditCategoryDialog(
        category: current,
        onSave: (edited) async {
          final updated = Category(
            id: current.id,
            name: edited.name,
            groupingMethod: edited.groupingMethod,
            groupSize: edited.groupSize,
            courseId: current.courseId,
            groups: current.groups, // preservar grupos existentes
          );
          await _controller.updateCategory(updated);
          if (mounted) {
            Get.snackbar(
              'Categoría actualizada',
              'Los cambios fueron guardados correctamente',
              backgroundColor: Theme.of(context).primaryColor,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar la categoría "${widget.category.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                _controller.deleteCategory(widget.category);
                Navigator.of(context).pop();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroupDialog(Category category) {
    final TextEditingController nameCtrl = TextEditingController(
      text: '[${category.name}] Grupo ${category.groups.length + 1}',
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Grupo'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                final newGroup = Group(
                  id: id, 
                  name: nameCtrl.text.trim(), 
                  categoryId: category.id,
                  courseId: category.courseId,
                  studentIds: const []
                );
                await _controller.addGroup(category.id, newGroup);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showEditGroupDialog(Category category, Group group) {
    final TextEditingController nameCtrl = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Grupo'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = Group(
                  id: group.id, 
                  name: nameCtrl.text.trim(), 
                  categoryId: group.categoryId,
                  courseId: group.courseId,
                  studentIds: group.studentIds, 
                  createdAt: group.createdAt
                );
                await _controller.updateGroup(category.id, updated);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteGroupConfirmation(Category category, Group group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Grupo'),
          content: Text('¿Seguro deseas eliminar "${group.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _controller.deleteGroup(category.id, group.id);
                if (mounted) Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onAddStudent(Category category, Group group) async {
    if (group.studentIds.length >= category.groupSize) {
      Get.snackbar(
        'Cupo lleno',
        'El grupo ya alcanzó el tamaño máximo (${category.groupSize}).',
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
      );
      return;
    }

    // Evitar estudiantes duplicados en la misma categoría
    final Set<String> assignedInCategory = category.groups
        .expand((g) => g.studentIds)
        .toSet();
    final List<String> available = widget.course.studentIds
        .where((s) => !assignedInCategory.contains(s))
        .toList();

    if (available.isEmpty) {
      Get.snackbar(
        'Sin estudiantes',
        'No hay estudiantes disponibles para asignar en esta categoría.',
        backgroundColor: Theme.of(context).primaryColor,
        colorText: Theme.of(context).colorScheme.onPrimary,
      );
      return;
    }

    final courseCtrl = Get.find<CourseController>();
    final users = await courseCtrl.getUsersByIds(available);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar estudiante al grupo'),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];
                final id = u['id'] ?? '';
                final name = u['name'] ?? id;
                final email = u['email'] ?? '';
                return ListTile(
                  leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                  title: Text(name),
                  subtitle: Text(email),
                  onTap: () async {
                    await _controller.enrollStudentToGroup(category.id, group.id, id);
                    if (mounted) Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRemoveStudent(Category category, Group group, String studentId) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quitar estudiante'),
          content: const Text('¿Deseas quitar este estudiante del grupo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _controller.removeStudentFromGroup(category.id, group.id, studentId);
                if (mounted) Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Quitar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRegenerateRandom(Category category) async {
    try {
      await _controller.regenerateRandomGroups(category.id);
      Get.snackbar(
        'Listo',
        'Grupos regenerados aleatoriamente.',
        backgroundColor: Theme.of(context).primaryColor,
        colorText: Theme.of(context).colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No fue posible regenerar: $e',
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
      );
    }
  }
}

class _CategoryInfoCard extends StatelessWidget {
  final Category category;
  final bool isTeacher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryInfoCard({
    required this.category,
    required this.isTeacher,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Método de agrupación: ${category.groupingMethod.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tamaño del grupo: ${category.groupSize}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isTeacher)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                        onPressed: onEdit,
                        tooltip: 'Editar categoría',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        onPressed: onDelete,
                        tooltip: 'Eliminar categoría',
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  final bool isTeacher;

  const _EmptyGroupsState({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay grupos creados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTeacher 
                ? 'Crea grupos para organizar a los estudiantes'
                : 'Los grupos aparecerán aquí cuando el profesor los cree',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GroupsList extends StatelessWidget {
  final List<Group> groups;
  final bool isTeacher;
  final Category category;
  final String? currentUserId;
  final bool userAlreadyAssigned;
  final Function(Group) onEditGroup;
  final Function(Group) onDeleteGroup;
  final Function(Group) onAddStudent;
  final Function(Group, String) onRemoveStudent;
  final Map<String, Map<String, String>> userMap;
  final Future<void> Function(Group) onJoinGroup;

  const _GroupsList({
    required this.groups,
    required this.isTeacher,
    required this.category,
    required this.currentUserId,
    required this.userAlreadyAssigned,
    required this.onEditGroup,
    required this.onDeleteGroup,
    required this.onAddStudent,
    required this.onRemoveStudent,
    required this.userMap,
    required this.onJoinGroup,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Text(
                        'G${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${group.studentIds.length} estudiantes',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTeacher)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.person_add, color: Theme.of(context).primaryColor),
                            onPressed: () => onAddStudent(group),
                            tooltip: 'Agregar estudiante',
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                            onPressed: () => onEditGroup(group),
                            tooltip: 'Editar grupo',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                            onPressed: () => onDeleteGroup(group),
                            tooltip: 'Eliminar grupo',
                          ),
                        ],
                      )
                    else if (category.groupingMethod.name == 'selfAssigned')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentUserId != null) ...[
                            if (group.studentIds.contains(currentUserId))
                              TextButton(
                                onPressed: () async {
                                  if (currentUserId == null) return;
                                  await onRemoveStudent(group, currentUserId!);
                                },
                                child: Text(
                                  'Salir',
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                              )
                            else if (!userAlreadyAssigned &&
                                group.studentIds.length < category.groupSize)
                              TextButton.icon(
                                onPressed: () => onJoinGroup(group),
                                icon: Icon(Icons.person_add,
                                    color: Theme.of(context).primaryColor),
                                label: Text('Unirme',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    )),
                              )
                            else if (userAlreadyAssigned &&
                                group.studentIds.length < category.groupSize)
                              TextButton(
                                onPressed: () async {
                                  // Cambiarse de grupo: quitar del actual y unirse a este
                                  try {
                                    final currentGroup = category.groups.firstWhere(
                                      (g) => g.studentIds.contains(currentUserId!),
                                      orElse: () => group,
                                    );
                                    if (currentGroup.id != group.id) {
                                      await onRemoveStudent(currentGroup, currentUserId!);
                                    }
                                    await onJoinGroup(group);
                                  } catch (_) {}
                                },
                                child: Text(
                                  'Cambiarme',
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ]
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (group.studentIds.isEmpty)
                  Text(
                    'Sin estudiantes asignados',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: group.studentIds.map((sid) {
                      final display = userMap[sid];
                      final name = (display != null && (display['name'] ?? '').isNotEmpty)
                          ? display['name']!
                          : 'Usuario ${sid.length > 8 ? sid.substring(0, 8) : sid}';
                      return Chip(
                        label: Text(name),
                        onDeleted: isTeacher ? () => onRemoveStudent(group, sid) : null,
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
