import '../../domain/models/category.dart';

abstract class ICategorySource {
  Future<List<Category>> getCategories();
  Future<Category> getCategoryById(String id);
  Future<List<Category>> getCategoriesByCourseId(String courseId);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
