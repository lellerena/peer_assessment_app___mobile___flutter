import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
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
      print("Getting categories for course: $courseId from Roble");
      
      _categories.value = await categoryUseCase.getCategoriesByCourseId(courseId);
      print("Categories loaded from Roble: ${_categories.length}");
      
    } catch (e) {
      print("Error loading categories from Roble: $e");
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
            categoryId: category.id,
            courseId: courseId,
            studentIds: [],
          ),
        );
      } else if (category.groupingMethod == CategoryModel.GroupingMethod.random) {
        // Para método random, crear grupos automáticamente con estudiantes aleatorios
        await _createRandomGroupsForCategory(category, initialGroups);
      }

      final categoryWithCourseId = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: courseId,
        groups: initialGroups,
      );

      // Agregar a Roble
      await categoryUseCase.addCategory(categoryWithCourseId);
      print("Category added to Roble successfully");
      
      // Si se crearon grupos automáticamente, guardarlos individualmente en Roble
      if (category.groupingMethod == CategoryModel.GroupingMethod.random && initialGroups.isNotEmpty) {
        for (final group in initialGroups) {
          try {
            await categoryUseCase.addGroup(categoryWithCourseId.id, group);
            print("Group ${group.name} added to Roble successfully");
          } catch (e) {
            print("Error adding group ${group.name} to Roble: $e");
            // Continuar con los demás grupos aunque uno falle
          }
        }
      }
      
      // Actualizar la lista local
      _categories.add(categoryWithCourseId);
      
      // Forzar actualización de la UI
      update();
      
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
      final currentCategory = _categories.firstWhere((c) => c.id == category.id);
      
      final updated = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: courseId,
        groups: currentCategory.groups, // Preservar grupos existentes
      );
      
      // Actualizar en Roble
      await categoryUseCase.updateCategory(updated);
      print("Category updated in Roble successfully");
      
      // Actualizar la lista local
      final index = _categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _categories[index] = updated;
      }
      
      // Forzar actualización de la UI
      update();
      
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
      
      // Eliminar de Roble
      await categoryUseCase.deleteCategory(category);
      print("Category deleted successfully from Roble");
      
      // Actualizar la lista local
      _categories.removeWhere((c) => c.id == category.id);
      
      // Forzar actualización de la UI
      update();
      
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
      
      // Agregar grupo a Roble
      await categoryUseCase.addGroup(categoryId, group);
      print("Group added successfully to Roble");
      
      // Actualizar la lista local
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex != -1) {
        final category = _categories[categoryIndex];
        final updatedGroups = List<CategoryModel.Group>.from(category.groups)..add(group);
        final updatedCategory = CategoryModel.Category(
          id: category.id,
          name: category.name,
          groupingMethod: category.groupingMethod,
          groupSize: category.groupSize,
          courseId: category.courseId,
          groups: updatedGroups,
        );
        _categories[categoryIndex] = updatedCategory;
      }
      
      // Forzar actualización de la UI
      update();
      
      Get.snackbar(
        'Éxito',
        'Grupo creado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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
      
      // Eliminar grupo de Roble
      await categoryUseCase.deleteGroup(categoryId, groupId);
      
      // Actualizar la lista local
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex != -1) {
        final category = _categories[categoryIndex];
        final updatedGroups = category.groups.where((group) => group.id != groupId).toList();
        final updatedCategory = CategoryModel.Category(
          id: category.id,
          name: category.name,
          groupingMethod: category.groupingMethod,
          groupSize: category.groupSize,
          courseId: category.courseId,
          groups: updatedGroups,
        );
        _categories[categoryIndex] = updatedCategory;
      }
      
      // Forzar actualización de la UI
      update();
      
      Get.snackbar(
        'Éxito',
        'Grupo eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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

      // Inscribir estudiante en Roble
      await categoryUseCase.enrollStudentToGroup(categoryId, groupId, studentId);
      
      // Actualizar la lista local
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex != -1) {
        final category = _categories[categoryIndex];
        final updatedGroups = category.groups.map((group) {
          if (group.id == groupId && !group.studentIds.contains(studentId)) {
            return CategoryModel.Group(
              id: group.id,
              name: group.name,
              categoryId: group.categoryId,
              courseId: group.courseId,
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
        _categories[categoryIndex] = updatedCategory;
      }
      
      // Forzar actualización de la UI
      update();

      Get.snackbar(
        'Éxito',
        'Estudiante inscrito correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error enrolling student to group: $e");
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

      // Remover estudiante de Roble
      await categoryUseCase.removeStudentFromGroup(categoryId, groupId, studentId);
      
      // Actualizar la lista local
      final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
      if (categoryIndex != -1) {
        final category = _categories[categoryIndex];
        final updatedGroups = category.groups.map((group) {
          if (group.id == groupId) {
            return CategoryModel.Group(
              id: group.id,
              name: group.name,
              categoryId: group.categoryId,
              courseId: group.courseId,
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
        _categories[categoryIndex] = updatedCategory;
      }
      
      // Forzar actualización de la UI
      update();

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

  // Método privado para crear grupos aleatorios al crear una categoría
  Future<void> _createRandomGroupsForCategory(
    CategoryModel.Category category,
    List<CategoryModel.Group> initialGroups,
  ) async {
    try {
      // Obtener todos los estudiantes inscritos en el curso
      final courseUseCase = Get.find<CourseUseCase>();
      final enrolledStudents = await courseUseCase.getEnrolledUserIds(courseId);
      print("Found ${enrolledStudents.length} enrolled students for random grouping");

      // Solo crear grupos si hay estudiantes inscritos
      if (enrolledStudents.isEmpty) {
        print("No enrolled students found, skipping random group creation");
        return;
      }

      // Crear grupos aleatorios
      final int groupSize = category.groupSize;
      final int totalGroups = (enrolledStudents.length / groupSize).ceil();

      // Mezclar estudiantes aleatoriamente
      enrolledStudents.shuffle();

      for (int i = 0; i < totalGroups; i++) {
        final startIndex = i * groupSize;
        final endIndex = (startIndex + groupSize).clamp(0, enrolledStudents.length);
        final members = enrolledStudents.sublist(startIndex, endIndex);

        initialGroups.add(
          CategoryModel.Group(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
            name: '[${category.name}] Grupo ${i + 1}',
            categoryId: category.id,
            courseId: category.courseId,
            studentIds: members,
          ),
        );
        
        print("Created group: ${initialGroups.last.name} with ${members.length} students: $members");
      }

      print("Created ${initialGroups.length} random groups with ${enrolledStudents.length} students");
    } catch (e) {
      print("Error creating random groups: $e");
      // No lanzar error, permitir continuar sin grupos
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

      // Obtener todos los estudiantes inscritos en el curso
      final courseUseCase = Get.find<CourseUseCase>();
      final enrolledStudents = await courseUseCase.getEnrolledUserIds(courseId);
      print("Found ${enrolledStudents.length} enrolled students for random grouping");

      // Crear grupos aleatorios
      final List<CategoryModel.Group> newGroups = [];
      final int groupSize = current.groupSize;
      final int totalGroups = (enrolledStudents.length / groupSize).ceil();

      // Mezclar estudiantes aleatoriamente
      enrolledStudents.shuffle();

      for (int i = 0; i < totalGroups; i++) {
        final startIndex = i * groupSize;
        final endIndex = (startIndex + groupSize).clamp(0, enrolledStudents.length);
        final members = enrolledStudents.sublist(startIndex, endIndex);

        newGroups.add(
          CategoryModel.Group(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
            name: '[${current.name}] Grupo ${i + 1}',
            categoryId: current.id,
            courseId: current.courseId,
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

      // Actualizar en Roble
      await categoryUseCase.updateCategory(updated);
      print("Random groups regenerated in Roble successfully");

      // Guardar cada grupo individualmente en la tabla groups de Roble
      for (final group in newGroups) {
        try {
          await categoryUseCase.addGroup(categoryId, group);
          print("Group ${group.name} added to Roble successfully");
        } catch (e) {
          print("Error adding group ${group.name} to Roble: $e");
          // Continuar con los demás grupos aunque uno falle
        }
      }

      // Actualizar lista en memoria
      final index = _categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        final updatedCategories = List<CategoryModel.Category>.from(_categories);
        updatedCategories[index] = updated;
        _categories.value = updatedCategories;
      }
      
      // Forzar actualización de la UI
      update();
    } catch (e) {
      errorMessage.value = 'Error regenerating random groups: $e';
    } finally {
      isLoading.value = false;
    }
  }
}