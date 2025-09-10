import '../models/category.dart';
import '../repositories/i_category_repository.dart';

class CategoryUseCase {
  final ICategoryRepository _repository;

  CategoryUseCase(this._repository);

  Future<List<Category>> getCategories(String courseId) async =>
      await _repository.getCategories(courseId);

  Future<bool> addCategory(Category category) async =>
      await _repository.addCategory(category);

  Future<bool> updateCategory(Category category) async =>
      await _repository.updateCategory(category);

  Future<bool> deleteCategory(Category category) async =>
      await _repository.deleteCategory(category);
}
