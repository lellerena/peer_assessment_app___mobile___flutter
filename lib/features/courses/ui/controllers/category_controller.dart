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

  List<CategoryModel.Category> get categories => _categories;

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
      // Asegurar que el courseId se conserve al actualizar
      final updated = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: courseId,
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
      await categoryUseCase.deleteCategory(category);
      await getCategories(); // Refresh the list
    } catch (e) {
      print("Error deleting category: $e");
      errorMessage.value = "Error deleting category: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // CRUD grupos
  Future<void> addGroup(String categoryId, CategoryModel.Group group) async {
    try {
      isLoading.value = true;
      await categoryUseCase.addGroup(categoryId, group);
      await getCategories();
    } catch (e) {
      errorMessage.value = "Error adding group: $e";
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
      await categoryUseCase.deleteGroup(categoryId, groupId);
      await getCategories();
    } catch (e) {
      errorMessage.value = "Error deleting group: $e";
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
      await categoryUseCase.enrollStudentToGroup(
        categoryId,
        groupId,
        studentId,
      );
      await getCategories();
    } catch (e) {
      errorMessage.value = "Error enrolling student: $e";
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
      await categoryUseCase.removeStudentFromGroup(
        categoryId,
        groupId,
        studentId,
      );
      await getCategories();
    } catch (e) {
      errorMessage.value = "Error removing student: $e";
    } finally {
      isLoading.value = false;
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
