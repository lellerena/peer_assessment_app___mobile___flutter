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
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            category.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Grouping: ${category.groupingMethod.name} / Size: ${category.groupSize}',
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
}
