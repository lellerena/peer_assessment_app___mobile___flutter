import '../models/index.dart';
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

  // CRUD grupos
  Future<void> addGroup(String categoryId, Group group) async =>
      await _repository.addGroup(categoryId, group);

  Future<void> updateGroup(String categoryId, Group group) async =>
      await _repository.updateGroup(categoryId, group);

  Future<void> deleteGroup(String categoryId, String groupId) async =>
      await _repository.deleteGroup(categoryId, groupId);

  Future<void> enrollStudentToGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async =>
      await _repository.enrollStudentToGroup(categoryId, groupId, studentId);

  Future<void> removeStudentFromGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async =>
      await _repository.removeStudentFromGroup(categoryId, groupId, studentId);
}
