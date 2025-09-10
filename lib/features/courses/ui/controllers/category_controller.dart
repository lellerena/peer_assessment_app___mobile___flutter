import 'package:get/get.dart';
import '../../domain/models/category.dart' as CategoryModel;
import '../../domain/usecases/category_usecase.dart';

class CategoryController extends GetxController {
  final RxList<CategoryModel.Category> _categories = <CategoryModel.Category>[].obs;
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

  getCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print("Getting categories for course: $courseId");
      _categories.value = await categoryUseCase.getCategories(courseId);
    } catch (e) {
      print("Error getting categories: $e");
      errorMessage.value = "Error loading categories: $e";
      _categories.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  addCategory(CategoryModel.Category category) async {
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

  updateCategory(CategoryModel.Category category) async {
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

  deleteCategory(CategoryModel.Category category) async {
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
}
