import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/category.dart';
import '../../domain/usecases/category_usecase.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../controllers/category_controller.dart';
import '../widgets/add_edit_category_dialog.dart';
import '../widgets/category_list_tile.dart';

class CategoryPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  const CategoryPage({super.key, required this.courseId, required this.courseName});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    // Tag único para este curso
    final String controllerTag = 'category_controller_$courseId';
    
    // Obtener o crear el controlador específico para este curso
    CategoryController controller;
    
    if (Get.isRegistered<CategoryController>(tag: controllerTag)) {
      controller = Get.find<CategoryController>(tag: controllerTag);
    } else {
      controller = Get.put(
        CategoryController(Get.find<CategoryUseCase>(), Get.find<CategoryLocalDataSource>(), courseId), 
        tag: controllerTag
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorías - $courseName'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // No eliminar el controlador aquí para evitar problemas con category_detail_page
            Get.back();
          },
        ),
      ),
      body: Obx(() {
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
                  color: colorScheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: colorScheme.error),
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
                  color: colorScheme.secondary,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No categories found.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a new category for this course using the button below.',
                  style: TextStyle(color: colorScheme.secondary),
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
              onDelete: () =>
                  _showDeleteConfirmation(context, controller, category),
              isTeacher: true, // En la página de categorías siempre es profesor
              course: null, // No hay curso específico en la página de categorías
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
