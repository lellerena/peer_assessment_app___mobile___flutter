import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../controller/category_controller.dart';
import '../widgets/add_edit_category_dialog.dart';
import '../widgets/category_list_tile.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.find<CategoryController>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 80,
                  color: colorScheme.secondary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No categories found.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a new category using the button below.',
                  style: TextStyle(color: colorScheme.secondary),
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
              onDelete: () =>
                  _showDeleteConfirmation(context, controller, category),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, controller),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

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
            // The ID is preserved from the original category object
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
}
