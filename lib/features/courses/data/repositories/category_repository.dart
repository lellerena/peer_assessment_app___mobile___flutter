import '/features/courses/data/datasources/i_category_source.dart';

import '../../domain/repositories/i_category_repository.dart';
import '../../domain/models/index.dart';

class CategoryRepository implements ICategoryRepository {
  final ICategorySource localDataSource;

  CategoryRepository(this.localDataSource);

  @override
  Future<List<Category>> getCategories() async =>
      await localDataSource.getCategories();

  @override
  Future<Category> getCategoryById(String id) async =>
      await localDataSource.getCategoryById(id);

  @override
  Future<List<Category>> getCategoriesByCourseId(String courseId) async =>
      await localDataSource.getCategoriesByCourseId(courseId);

  @override
  Future<bool> addCategory(Category category) async {
    await localDataSource.addCategory(category);
    return true;
  }

  @override
  Future<bool> updateCategory(Category category) async {
    await localDataSource.updateCategory(category);
    return true;
  }

  @override
  Future<bool> deleteCategory(Category category) async {
    await localDataSource.deleteCategory(category.id);
    return true;
  }

  // CRUD grupos
  @override
  Future<void> addGroup(String categoryId, Group group) async {
    await localDataSource.addGroup(categoryId, group);
  }

  @override
  Future<void> updateGroup(String categoryId, Group group) async {
    await localDataSource.updateGroup(categoryId, group);
  }

  @override
  Future<void> deleteGroup(String categoryId, String groupId) async {
    await localDataSource.deleteGroup(categoryId, groupId);
  }

  @override
  Future<void> enrollStudentToGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    await localDataSource.enrollStudentToGroup(categoryId, groupId, studentId);
  }

  @override
  Future<void> removeStudentFromGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    await localDataSource.removeStudentFromGroup(
      categoryId,
      groupId,
      studentId,
    );
  }
}
