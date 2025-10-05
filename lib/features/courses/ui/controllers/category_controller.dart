import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/index.dart' as CategoryModel;

import '../../domain/usecases/category_usecase.dart';
import '../../domain/usecases/course_usecase.dart';

class CategoryController extends GetxController {
  final RxList<CategoryModel.Category> _categories =
      <CategoryModel.Category>[].obs;
  final CategoryUseCase categoryUseCase;
  final String courseId;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  CategoryController(this.categoryUseCase, this.courseId);

  RxList<CategoryModel.Category> get categories => _categories;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("Getting categories for course: $courseId");
      _categories.value = await categoryUseCase.getCategoriesByCourseId(
        courseId,
      );
    } catch (e) {
      print("Error getting categories: $e");
      errorMessage.value = "Error loading categories: $e";
      _categories.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(CategoryModel.Category category) async {
    try {
      isLoading.value = true;

      // Create category with the current courseId
      final List<CategoryModel.Group> initialGroups = <CategoryModel.Group>[];

      // Generación automática de grupos según método
      // - selfAssigned: crear al menos un grupo vacío como contenedor, con nombre identificable
      // - random/manual: no crear grupos automáticamente aquí (random requiere distribución de estudiantes)
      if (category.groupingMethod == CategoryModel.GroupingMethod.selfAssigned) {
        initialGroups.add(
          CategoryModel.Group(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: '[${category.name}] Grupo 1',
            studentIds: const [],
          ),
        );
      } else if (category.groupingMethod == CategoryModel.GroupingMethod.random) {
        // Distribuir estudiantes inscritos en el curso en grupos de tamaño groupSize
        final courseUseCase = Get.find<CourseUseCase>();
        final List<String> enrolled = await courseUseCase.getEnrolledUserIds(courseId);
        final List<String> shuffled = List<String>.from(enrolled)..shuffle();

        final int groupSize = category.groupSize > 0 ? category.groupSize : 2;
        final int groupCount = (shuffled.length / groupSize).ceil();

        for (int i = 0; i < groupCount; i++) {
          final start = i * groupSize;
          final end = (start + groupSize) > shuffled.length ? shuffled.length : (start + groupSize);
          final members = shuffled.sublist(start, end);
          initialGroups.add(
            CategoryModel.Group(
              id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
              name: '[${category.name}] Grupo ${i + 1}',
              studentIds: members,
            ),
          );
        }
      }

      final categoryWithCourseId = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: courseId,
        groups: initialGroups,
      );

      await categoryUseCase.addCategory(categoryWithCourseId);
      await getCategories(); // Refresh the list
    } catch (e) {
      print("Error adding category: $e");
      errorMessage.value = "Error adding category: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(CategoryModel.Category category) async {
    try {
      isLoading.value = true;
      
      // Obtener la categoría actual para preservar los grupos
      final currentCategory = _categories.firstWhere(
        (c) => c.id == category.id,
        orElse: () => category,
      );
      
      // Asegurar que el courseId se conserve al actualizar y preservar grupos
      final updated = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: courseId,
        groups: currentCategory.groups, // Preservar grupos existentes
      );
      
      await categoryUseCase.updateCategory(updated);
      await getCategories(); // Refresh the list
    } catch (e) {
      print("Error updating category: $e");
      errorMessage.value = "Error updating category: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(CategoryModel.Category category) async {
    try {
      isLoading.value = true;
      
      try {
        await categoryUseCase.deleteCategory(category);
        await getCategories(); // Refresh the list after successful deletion
        Get.snackbar(
          'Éxito',
          'Categoría eliminada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("Error deleting category from Roble, using local fallback: $e");
        
        // Fallback: eliminar categoría localmente
        await _deleteCategoryLocally(category.id);
        
        Get.snackbar(
          'Éxito',
          'Categoría eliminada (almacenada localmente)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error deleting category: $e");
      errorMessage.value = "Error deleting category: $e";
      Get.snackbar(
        'Error',
        'No se pudo eliminar la categoría: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // CRUD grupos
  Future<void> addGroup(String categoryId, CategoryModel.Group group) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      try {
        await categoryUseCase.addGroup(categoryId, group);
        await getCategories(); // Refresh the list after successful creation
        Get.snackbar(
          'Éxito',
          'Grupo creado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("Error adding group to Roble, using local fallback: $e");
        
        // Fallback: agregar grupo localmente
        await _addGroupLocally(categoryId, group);
        
        Get.snackbar(
          'Éxito',
          'Grupo creado (almacenado localmente)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error adding group: $e");
      errorMessage.value = "Error adding group: $e";
      Get.snackbar(
        'Error',
        'No se pudo crear el grupo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroup(String categoryId, CategoryModel.Group group) async {
    try {
      isLoading.value = true;
      await categoryUseCase.updateGroup(categoryId, group);
      await getCategories();
    } catch (e) {
      errorMessage.value = "Error updating group: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGroup(String categoryId, String groupId) async {
    try {
      isLoading.value = true;
      
      try {
        await categoryUseCase.deleteGroup(categoryId, groupId);
        Get.snackbar(
          'Éxito',
          'Grupo eliminado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("Error deleting group from Roble, using local fallback: $e");
        
        // Fallback: eliminar grupo localmente
        await _deleteGroupLocally(categoryId, groupId);
        
        Get.snackbar(
          'Éxito',
          'Grupo eliminado (almacenado localmente)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error deleting group: $e");
      errorMessage.value = "Error deleting group: $e";
      Get.snackbar(
        'Error',
        'No se pudo eliminar el grupo: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enrollStudentToGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    try {
      isLoading.value = true;
      
      try {
        await categoryUseCase.enrollStudentToGroup(
          categoryId,
          groupId,
          studentId,
        );
        await getCategories(); // Refresh the list after successful enrollment
        Get.snackbar(
          'Éxito',
          'Estudiante inscrito correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("Error enrolling student to Roble, using local fallback: $e");
        
        // Fallback: inscribir estudiante localmente
        await _enrollStudentLocally(categoryId, groupId, studentId);
        
        Get.snackbar(
          'Éxito',
          'Estudiante inscrito (almacenado localmente)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = "Error enrolling student: $e";
      Get.snackbar(
        'Error',
        'No se pudo inscribir el estudiante: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeStudentFromGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    try {
      isLoading.value = true;
      
      try {
        await categoryUseCase.removeStudentFromGroup(
          categoryId,
          groupId,
          studentId,
        );
        await getCategories();
        Get.snackbar(
          'Éxito',
          'Estudiante removido correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("Error removing student from Roble, using local fallback: $e");
        
        // Fallback: remover estudiante localmente
        await _removeStudentLocally(categoryId, groupId, studentId);
        
        Get.snackbar(
          'Éxito',
          'Estudiante removido (almacenado localmente)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error removing student: $e");
      errorMessage.value = "Error removing student: $e";
      Get.snackbar(
        'Error',
        'No se pudo remover el estudiante: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Método de fallback local para agregar grupos
  Future<void> _addGroupLocally(String categoryId, CategoryModel.Group group) async {
    try {
      print("Adding group locally: ${group.name} to category: $categoryId");
      
      // Obtener la categoría actual
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex == -1) {
        print("Category not found in local list");
        return;
      }
      
      final category = _categories[categoryIndex];
      print("Found category: ${category.name} with ${category.groups.length} groups");
      
      // Crear nueva categoría con el grupo agregado
      final updatedGroups = List<CategoryModel.Group>.from(category.groups)..add(group);
      print("Updated groups count: ${updatedGroups.length}");
      
      final updatedCategory = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      
      // Actualizar la lista local
      final updatedCategories = List<CategoryModel.Category>.from(_categories);
      updatedCategories[categoryIndex] = updatedCategory;
      _categories.value = updatedCategories;
      
      print("Updated category at index $categoryIndex");
      print("Categories updated. Total categories: ${_categories.length}");
      print("Category ${updatedCategory.name} now has ${updatedCategory.groups.length} groups");
    } catch (e) {
      print("Error adding group locally: $e");
      rethrow;
    }
  }

  // Método de fallback local para eliminar categorías
  Future<void> _deleteCategoryLocally(String categoryId) async {
    try {
      print("Deleting category locally: $categoryId");
      
      // Remover la categoría de la lista local
      final updatedCategories = _categories.where((c) => c.id != categoryId).toList();
      _categories.value = updatedCategories;
      
      print("Category deleted successfully. Remaining categories: ${_categories.length}");
    } catch (e) {
      print("Error deleting category locally: $e");
      rethrow;
    }
  }

  // Método de fallback local para eliminar grupos
  Future<void> _deleteGroupLocally(String categoryId, String groupId) async {
    try {
      print("Deleting group locally: $groupId from category: $categoryId");
      
      // Obtener la categoría actual
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex == -1) {
        print("Category not found in local list");
        return;
      }
      
      final category = _categories[categoryIndex];
      print("Found category: ${category.name} with ${category.groups.length} groups");
      
      // Remover el grupo de la categoría
      final updatedGroups = category.groups.where((group) => group.id != groupId).toList();
      print("Updated groups count: ${updatedGroups.length}");
      
      final updatedCategory = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      
      // Actualizar la lista local
      final updatedCategories = List<CategoryModel.Category>.from(_categories);
      updatedCategories[categoryIndex] = updatedCategory;
      _categories.value = updatedCategories;
      
      print("Updated category at index $categoryIndex");
      print("Group deleted successfully. Category ${updatedCategory.name} now has ${updatedCategory.groups.length} groups");
    } catch (e) {
      print("Error deleting group locally: $e");
      rethrow;
    }
  }

  // Método de fallback local para remover estudiantes
  Future<void> _removeStudentLocally(String categoryId, String groupId, String studentId) async {
    try {
      print("Removing student locally: $studentId from group: $groupId in category: $categoryId");
      
      // Obtener la categoría actual
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex == -1) {
        print("Category not found in local list");
        return;
      }
      
      final category = _categories[categoryIndex];
      print("Found category: ${category.name} with ${category.groups.length} groups");
      
      // Encontrar el grupo y remover el estudiante
      final updatedGroups = category.groups.map((group) {
        if (group.id == groupId && group.studentIds.contains(studentId)) {
          print("Removing student from group: ${group.name}");
          return CategoryModel.Group(
            id: group.id,
            name: group.name,
            studentIds: group.studentIds.where((id) => id != studentId).toList(),
            createdAt: group.createdAt,
          );
        }
        return group;
      }).toList();
      
      final updatedCategory = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      
      // Actualizar la lista local
      final updatedCategories = List<CategoryModel.Category>.from(_categories);
      updatedCategories[categoryIndex] = updatedCategory;
      _categories.value = updatedCategories;
      
      print("Updated category at index $categoryIndex");
      print("Student removed successfully. Category ${updatedCategory.name} now has ${updatedCategory.groups.length} groups");
    } catch (e) {
      print("Error removing student locally: $e");
      rethrow;
    }
  }

  // Método de fallback local para inscribir estudiantes
  Future<void> _enrollStudentLocally(String categoryId, String groupId, String studentId) async {
    try {
      print("Enrolling student locally: $studentId to group: $groupId in category: $categoryId");
      
      // Obtener la categoría actual
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex == -1) {
        print("Category not found in local list");
        return;
      }
      
      final category = _categories[categoryIndex];
      print("Found category: ${category.name} with ${category.groups.length} groups");
      
      // Encontrar el grupo y agregar el estudiante
      final updatedGroups = category.groups.map((group) {
        if (group.id == groupId && !group.studentIds.contains(studentId)) {
          print("Adding student to group: ${group.name}");
          return CategoryModel.Group(
            id: group.id,
            name: group.name,
            studentIds: List<String>.from(group.studentIds)..add(studentId),
            createdAt: group.createdAt,
          );
        }
        return group;
      }).toList();
      
      final updatedCategory = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      
      // Actualizar la lista local
      final updatedCategories = List<CategoryModel.Category>.from(_categories);
      updatedCategories[categoryIndex] = updatedCategory;
      _categories.value = updatedCategories;
      
      print("Updated category at index $categoryIndex");
      print("Student enrolled successfully. Category ${updatedCategory.name} now has ${updatedCategory.groups.length} groups");
    } catch (e) {
      print("Error enrolling student locally: $e");
      rethrow;
    }
  }

  // Regenerar agrupación aleatoria: redistribuye a TODOS los inscritos en grupos nuevos
  Future<void> regenerateRandomGroups(String categoryId) async {
    try {
      isLoading.value = true;
      // Obtener categoría actual
      final current = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );
      if (current.groupingMethod != CategoryModel.GroupingMethod.random) {
        throw Exception('Solo aplica para categorías de tipo random');
      }

      final courseUseCase = Get.find<CourseUseCase>();
      final List<String> enrolled = await courseUseCase.getEnrolledUserIds(courseId);
      final List<String> shuffled = List<String>.from(enrolled)..shuffle();
      final int groupSize = current.groupSize > 0 ? current.groupSize : 2;
      final int groupCount = (shuffled.length / groupSize).ceil();

      final List<CategoryModel.Group> newGroups = [];
      for (int i = 0; i < groupCount; i++) {
        final start = i * groupSize;
        final end = (start + groupSize) > shuffled.length ? shuffled.length : (start + groupSize);
        final members = shuffled.sublist(start, end);
        newGroups.add(
          CategoryModel.Group(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
            name: '[${current.name}] Grupo ${i + 1}',
            studentIds: members,
          ),
        );
      }

      final updated = CategoryModel.Category(
        id: current.id,
        name: current.name,
        groupingMethod: current.groupingMethod,
        groupSize: current.groupSize,
        courseId: current.courseId,
        groups: newGroups,
      );

      await categoryUseCase.updateCategory(updated);
      await getCategories();
    } catch (e) {
      errorMessage.value = 'Error regenerating random groups: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
