import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../domain/models/index.dart' as CategoryModel;

import '../../domain/usecases/category_usecase.dart';
import '../../domain/usecases/course_usecase.dart';
import '../../data/datasources/category_local_data_source.dart';

class CategoryController extends GetxController {
  final RxList<CategoryModel.Category> _categories =
      <CategoryModel.Category>[].obs;
  final CategoryUseCase categoryUseCase;
  final CategoryLocalDataSource localDataSource;
  final String courseId;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  CategoryController(this.categoryUseCase, this.localDataSource, this.courseId);

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
      
      // PRIORIZAR ALMACENAMIENTO LOCAL - Los cambios locales son la fuente de verdad
      try {
        _categories.value = await localDataSource.getCategories(courseId);
        print("Categories loaded from local storage: ${_categories.length}");
        
        // Solo sincronizar con Roble en segundo plano si hay conexión
        try {
          final robleCategories = await categoryUseCase.getCategoriesByCourseId(courseId);
          print("Roble categories available: ${robleCategories.length}");
          // No sobrescribir los datos locales, solo sincronizar en segundo plano
        } catch (e) {
          print("Roble sync failed, using local data only: $e");
        }
      } catch (e) {
        print("Error loading from local storage: $e");
        // Solo si falla completamente el local, intentar Roble
        try {
          _categories.value = await categoryUseCase.getCategoriesByCourseId(courseId);
          print("Categories loaded from Roble as fallback: ${_categories.length}");
        } catch (robleError) {
          print("Both local and Roble failed: $robleError");
          _categories.value = [];
        }
      }
    } catch (e) {
      print("Critical error getting categories: $e");
      errorMessage.value = "Error loading categories: $e";
      _categories.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(CategoryModel.Category category) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("Adding category: ${category.name}");

      // Create category with the current courseId
      final List<CategoryModel.Group> initialGroups = <CategoryModel.Group>[];

      // Generación automática de grupos según método
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

      // Intentar agregar a Roble primero
      try {
        await categoryUseCase.addCategory(categoryWithCourseId);
        print("Category added to Roble successfully");
      } catch (e) {
        print("Error adding category to Roble: $e");
      }
      
      // Siempre agregar localmente para persistencia
      await localDataSource.addCategory(categoryWithCourseId);
      print("Category added to local storage");
      
      // Actualizar la lista local
      _categories.add(categoryWithCourseId);
      
      Get.snackbar(
        'Éxito',
        'Categoría creada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding category: $e");
      errorMessage.value = "Error adding category: $e";
      Get.snackbar(
        'Error',
        'No se pudo crear la categoría: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(CategoryModel.Category category) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("Updating category: ${category.name}");
      
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
      
      // Intentar actualizar en Roble primero
      try {
        await categoryUseCase.updateCategory(updated);
        print("Category updated in Roble successfully");
      } catch (e) {
        print("Error updating category in Roble: $e");
      }
      
      // Siempre actualizar localmente para persistencia
      await localDataSource.updateCategory(updated);
      print("Category updated in local storage");
      
      // Actualizar la lista local
      final index = _categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _categories[index] = updated;
      }
      
      Get.snackbar(
        'Éxito',
        'Categoría actualizada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error updating category: $e");
      errorMessage.value = "Error updating category: $e";
      Get.snackbar(
        'Error',
        'No se pudo actualizar la categoría: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(CategoryModel.Category category) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("Attempting to delete category: ${category.name} (ID: ${category.id})");
      
      // Intentar eliminar desde Roble primero
      try {
        await categoryUseCase.deleteCategory(category);
        print("Category deleted successfully from Roble");
      } catch (e) {
        print("Error deleting category from Roble: $e");
      }
      
      // Siempre eliminar localmente para persistencia
      await localDataSource.deleteCategory(category.id);
      print("Category deleted from local storage");
      
      // Actualizar la lista local
      _categories.removeWhere((c) => c.id == category.id);
      
      Get.snackbar(
        'Éxito',
        'Categoría eliminada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Critical error deleting category: $e");
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
      
      print("Attempting to add group: ${group.name} to category: $categoryId");
      
      // Intentar agregar desde Roble primero
      try {
        await categoryUseCase.addGroup(categoryId, group);
        print("Group added successfully to Roble");
        
        // Actualizar la lista local inmediatamente
        await _updateCategoryWithNewGroup(categoryId, group);
        
        Get.snackbar(
          'Éxito',
          'Grupo creado correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("Error adding group to Roble: $e");
        
        // Fallback: agregar localmente
        print("Using local fallback for group creation");
        await _updateCategoryWithNewGroup(categoryId, group);
        
        Get.snackbar(
          'Éxito',
          'Grupo creado (almacenado localmente)',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Critical error adding group: $e");
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
      errorMessage.value = '';
      print("Attempting to enroll student: $studentId to group: $groupId in category: $categoryId");

      // 1) Optimista: actualizar local e interfaz de inmediato
      await _updateGroupWithStudent(categoryId, groupId, studentId, true);

      // 2) Disparar sincronización remota en segundo plano con timeout
      //    para evitar que la UI quede bloqueada si el backend no responde
      unawaited(Future(() async {
        try {
          await categoryUseCase
              .enrollStudentToGroup(categoryId, groupId, studentId)
              .timeout(const Duration(seconds: 3));
          print("Remote enroll OK");
        } catch (e) {
          print("Remote enroll failed or timed out: $e");
        }
      }));

      Get.snackbar(
        'Éxito',
        'Estudiante inscrito correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Critical error enrolling student: $e");
      errorMessage.value = "Error enrolling student: $e";
      Get.snackbar(
        'Error',
        'No se pudo inscribir el estudiante: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeStudentFromGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    try {
      errorMessage.value = '';
      print("Attempting to remove student: $studentId from group: $groupId in category: $categoryId");

      // 1) Optimista local
      await _updateGroupWithStudent(categoryId, groupId, studentId, false);

      // 2) Remoto en segundo plano con timeout
      unawaited(Future(() async {
        try {
          await categoryUseCase
              .removeStudentFromGroup(categoryId, groupId, studentId)
              .timeout(const Duration(seconds: 3));
          print("Remote remove OK");
        } catch (e) {
          print("Remote remove failed or timed out: $e");
        }
      }));

      Get.snackbar(
        'Éxito',
        'Estudiante removido correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Critical error removing student: $e");
      errorMessage.value = "Error removing student: $e";
      Get.snackbar(
        'Error',
        'No se pudo remover el estudiante: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Método para limpiar todos los datos locales y forzar uso solo de almacenamiento local
  Future<void> clearLocalData() async {
    try {
      await localDataSource.clearAllData();
      _categories.clear();
      print("All local data cleared, starting fresh");
    } catch (e) {
      print("Error clearing local data: $e");
    }
  }

  // Método para actualizar grupo con estudiante (agregar o remover)
  Future<void> _updateGroupWithStudent(String categoryId, String groupId, String studentId, bool add) async {
    try {
      print("Updating group with student: $studentId (add: $add)");
      
      // Encontrar la categoría en la lista
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex == -1) {
        print("Category not found: $categoryId");
        return;
      }
      
      final category = _categories[categoryIndex];
      print("Found category: ${category.name} with ${category.groups.length} groups");
      
      // Encontrar el grupo y actualizar la lista de estudiantes
      final updatedGroups = category.groups.map((group) {
        if (group.id == groupId) {
          List<String> updatedStudentIds;
          if (add) {
            // Agregar estudiante si no está ya en el grupo
            if (!group.studentIds.contains(studentId)) {
              updatedStudentIds = List<String>.from(group.studentIds)..add(studentId);
              print("Added student $studentId to group ${group.name}");
            } else {
              print("Student $studentId already in group ${group.name}");
              updatedStudentIds = group.studentIds;
            }
          } else {
            // Remover estudiante
            updatedStudentIds = group.studentIds.where((id) => id != studentId).toList();
            print("Removed student $studentId from group ${group.name}");
          }
          
          return CategoryModel.Group(
            id: group.id,
            name: group.name,
            studentIds: updatedStudentIds,
            createdAt: group.createdAt,
          );
        }
        return group;
      }).toList();
      
      // Crear categoría actualizada
      final updatedCategory = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      
      // Persistir localmente
      await localDataSource.updateCategory(updatedCategory);
      print("Category updated in local storage with student change");
      
      // Actualizar la lista local
      final updatedCategories = List<CategoryModel.Category>.from(_categories);
      updatedCategories[categoryIndex] = updatedCategory;
      _categories.value = updatedCategories;
      
      print("Group updated successfully. Group now has ${updatedGroups.firstWhere((g) => g.id == groupId).studentIds.length} students");
    } catch (e) {
      print("Error updating group with student: $e");
      rethrow;
    }
  }

  // Método para actualizar categoría con nuevo grupo
  Future<void> _updateCategoryWithNewGroup(String categoryId, CategoryModel.Group group) async {
    try {
      print("Updating category with new group: ${group.name}");
      
      // Encontrar la categoría en la lista
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex == -1) {
        print("Category not found: $categoryId");
        return;
      }
      
      final category = _categories[categoryIndex];
      print("Found category: ${category.name} with ${category.groups.length} groups");
      
      // Crear nueva lista de grupos con el grupo agregado
      final updatedGroups = List<CategoryModel.Group>.from(category.groups)..add(group);
      
      // Crear categoría actualizada
      final updatedCategory = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      
      // Persistir localmente
      await localDataSource.updateCategory(updatedCategory);
      print("Category updated in local storage with new group");
      
      // Actualizar la lista local
      final updatedCategories = List<CategoryModel.Category>.from(_categories);
      updatedCategories[categoryIndex] = updatedCategory;
      _categories.value = updatedCategories;
      
      print("Category updated successfully. Now has ${updatedCategory.groups.length} groups");
    } catch (e) {
      print("Error updating category with new group: $e");
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

      // Actualizar en backend (best-effort)
      try {
        await categoryUseCase.updateCategory(updated);
      } catch (_) {
        // Ignorar para no bloquear la UX; la fuente de verdad es local
      }

      // Persistir localmente para que la UI refleje el cambio de inmediato
      await localDataSource.updateCategory(updated);

      // Actualizar lista en memoria sin volver a cargar todo
      final index = _categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        final updatedCategories = List<CategoryModel.Category>.from(_categories);
        updatedCategories[index] = updated;
        _categories.value = updatedCategories;
      }
    } catch (e) {
      errorMessage.value = 'Error regenerating random groups: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
