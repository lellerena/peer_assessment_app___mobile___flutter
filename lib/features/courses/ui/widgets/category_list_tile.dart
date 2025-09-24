import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/models/course.dart';
import '../pages/category_detail_page.dart';

class CategoryListTile extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isTeacher;
  final Course? course;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    this.isTeacher = true,
    this.course,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      child: ListTile(
        onTap: () {
          if (course != null) {
            Get.to(() => CategoryDetailPage(
              category: category,
              course: course!,
              isTeacher: isTeacher,
            ));
          }
        },
        leading: CircleAvatar(
          backgroundColor: category.groups.isNotEmpty 
              ? colorScheme.secondaryContainer 
              : colorScheme.primaryContainer,
          child: Icon(
            category.groups.isNotEmpty ? Icons.groups : Icons.category,
            color: category.groups.isNotEmpty 
                ? colorScheme.onSecondaryContainer 
                : colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agrupación: ${_getGroupingMethodText(category.groupingMethod)} / Tamaño: ${category.groupSize}',
            ),
            if (category.groups.isNotEmpty)
              Text(
                '${category.groups.length} grupos • ${category.groups.fold<int>(0, (sum, group) => sum + group.studentIds.length)} estudiantes asignados',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: isTeacher ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.secondary),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: colorScheme.error),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ) : null,
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
