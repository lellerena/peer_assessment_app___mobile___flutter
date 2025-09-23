import 'package:get/get.dart';
import '../../domain/models/index.dart' as CategoryModel;

import '../../domain/usecases/category_usecase.dart';

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
      final categoryWithCourseId = CategoryModel.Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: courseId,
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
      await categoryUseCase.updateCategory(category);
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
}
