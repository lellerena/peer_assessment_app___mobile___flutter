import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';
import '../../domain/usecases/category_usecase.dart';
import '../controllers/category_controller.dart';
import '../../domain/models/course.dart';
import '../widgets/add_edit_group_dialog.dart';
import '../widgets/group_generation_dialog.dart';

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
  List<Group> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadGroups();
  }

  void _initializeController() {
    final String tag = 'category_controller_${widget.course.id}';
    if (Get.isRegistered<CategoryController>(tag: tag)) {
      _controller = Get.find<CategoryController>(tag: tag);
    } else {
      // Obtener el CategoryUseCase del contenedor de dependencias
      final categoryUseCase = Get.find<CategoryUseCase>();
      _controller = Get.put(CategoryController(categoryUseCase, widget.course.id), tag: tag);
    }
  }

  Future<void> _loadGroups() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Load groups from the category data
      // The category already contains groups, so we can use them directly
      if (mounted) {
        setState(() {
          _groups = List<Group>.from(widget.category.groups);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshCategory() async {
    try {
      await _controller.getCategories();
      // Find the updated category and refresh groups
      final updatedCategories = _controller.categories;
      final updatedCategory = updatedCategories.cast<Category?>().firstWhere(
        (cat) => cat?.id == widget.category.id,
        orElse: () => null,
      );
      
      if (updatedCategory != null && mounted) {
        setState(() {
          _groups = List<Group>.from(updatedCategory.groups);
        });
      }
    } catch (e) {
      print("Error refreshing category: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la categoría
          _CategoryInfoCard(
            category: widget.category,
            isTeacher: widget.isTeacher,
            onEdit: () => _showEditCategoryDialog(),
            onDelete: () => _showDeleteConfirmation(),
          ),
          
          const SizedBox(height: 24),
          
          // Sección de grupos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grupos (${_groups.length})',
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
                    if (widget.category.groupingMethod == GroupingMethod.random)
                      ElevatedButton.icon(
                        onPressed: () => _showGroupGenerationDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Generar'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showCreateGroupDialog(),
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
          
          // Lista de grupos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                    ? _EmptyGroupsState(isTeacher: widget.isTeacher)
                    : _GroupsList(
                        groups: _groups,
                        isTeacher: widget.isTeacher,
                        onEditGroup: (group) => _showEditGroupDialog(group),
                        onDeleteGroup: (group) => _showDeleteGroupConfirmation(group),
                      ),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog() {
    final currentCategory = widget.category;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // We need to import the AddEditCategoryDialog
        // For now, show a simple message
        return AlertDialog(
          title: const Text('Editar Categoría'),
          content: const Text('La edición de categorías mantendrá los grupos existentes.'),
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

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditGroupDialog(
          onSave: (Group group) async {
            try {
              await _controller.addGroup(widget.category.id, group);
              await _refreshCategory();
              Get.snackbar(
                'Éxito',
                'Grupo creado exitosamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.snackbar(
                'Error',
                'Error al crear el grupo: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          availableStudentIds: widget.course.studentIds,
          currentlyAssignedStudentIds: _getAllAssignedStudentIds(),
        );
      },
    );
  }

  void _showGroupGenerationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GroupGenerationDialog(
          onSave: (List<Group> groups) async {
            try {
              // Add all generated groups
              for (final group in groups) {
                await _controller.addGroup(widget.category.id, group);
              }
              await _refreshCategory();
              Get.snackbar(
                'Éxito',
                '${groups.length} grupos generados exitosamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.snackbar(
                'Error',
                'Error al generar grupos: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          availableStudentIds: _getUnassignedStudentIds(),
          defaultGroupSize: widget.category.groupSize,
        );
      },
    );
  }

  void _showEditGroupDialog(Group group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditGroupDialog(
          group: group,
          onSave: (Group updatedGroup) async {
            try {
              await _controller.updateGroup(widget.category.id, updatedGroup);
              await _refreshCategory();
              Get.snackbar(
                'Éxito',
                'Grupo actualizado exitosamente',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              Get.snackbar(
                'Error',
                'Error al actualizar el grupo: $e',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          availableStudentIds: widget.course.studentIds,
          currentlyAssignedStudentIds: _getAllAssignedStudentIds()
            ..removeWhere((id) => group.studentIds.contains(id)),
        );
      },
    );
  }

  void _showDeleteGroupConfirmation(Group group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar el grupo "${group.name}"?\n\n'
            'Los estudiantes quedarán sin asignar.',
          ),
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
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _controller.deleteGroup(widget.category.id, group.id);
                  await _refreshCategory();
                  Get.snackbar(
                    'Éxito',
                    'Grupo eliminado exitosamente',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Error al eliminar el grupo: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<String> _getAllAssignedStudentIds() {
    return _groups.expand((group) => group.studentIds).toList();
  }

  List<String> _getUnassignedStudentIds() {
    final assignedIds = _getAllAssignedStudentIds();
    return widget.course.studentIds
        .where((id) => !assignedIds.contains(id))
        .toList();
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
                        'Método de agrupación: ${_getGroupingMethodText(category.groupingMethod)}',
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
                      if (category.groups.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Grupos creados: ${category.groups.length}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  String _getGroupingMethodText(GroupingMethod method) {
    switch (method) {
      case GroupingMethod.random:
        return 'Aleatorio';
      case GroupingMethod.selfAssigned:
        return 'Auto-asignado';
      case GroupingMethod.manual:
        return 'Manual';
    }
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
                ? 'Crea grupos para organizar a los estudiantes.\n\nUsa "Generar" para grupos aleatorios o "Crear Grupo" para grupos manuales.'
                : 'Los grupos aparecerán aquí cuando el profesor los cree',
            style: const TextStyle(
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
  final Function(Group) onEditGroup;
  final Function(Group) onDeleteGroup;

  const _GroupsList({
    required this.groups,
    required this.isTeacher,
    required this.onEditGroup,
    required this.onDeleteGroup,
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
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    (index + 1).toString(),
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
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
