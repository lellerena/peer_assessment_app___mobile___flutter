import '../models/category.dart';
import '../repositories/i_category_repository.dart';

class CategoryUseCase {
  final ICategoryRepository _repository;

  CategoryUseCase(this._repository);

  Future<List<Category>> getCategories() async =>
      await _repository.getCategories();

  Future<Category> getCategoryById(String id) async =>
      await _repository.getCategoryById(id);

  Future<List<Category>> getCategoriesByCourseId(String courseId) async =>
      await _repository.getCategoriesByCourseId(courseId);

  Future<bool> addCategory(Category category) async =>
      await _repository.addCategory(category);

  Future<bool> updateCategory(Category category) async =>
      await _repository.updateCategory(category);

  Future<bool> deleteCategory(Category category) async =>
      await _repository.deleteCategory(category);
}
