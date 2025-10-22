import '/features/courses/data/datasources/i_category_source.dart';

import '../../domain/repositories/i_category_repository.dart';
import '../../domain/models/index.dart';

class CategoryRepository implements ICategoryRepository {
  final ICategorySource remoteDataSource;

  CategoryRepository(this.remoteDataSource);

  @override
  Future<List<Category>> getCategories() async =>
      await remoteDataSource.getCategories();

  @override
  Future<Category> getCategoryById(String id) async =>
      await remoteDataSource.getCategoryById(id);

  @override
  Future<List<Category>> getCategoriesByCourseId(String courseId) async =>
      await remoteDataSource.getCategoriesByCourseId(courseId);

  @override
  Future<bool> addCategory(Category category) async {
    await remoteDataSource.addCategory(category);
    return true;
  }

  @override
  Future<bool> updateCategory(Category category) async {
    await remoteDataSource.updateCategory(category);
    return true;
  }

  @override
  Future<bool> deleteCategory(Category category) async {
    await remoteDataSource.deleteCategory(category.id);
    return true;
  }

  // CRUD grupos
  @override
  Future<void> addGroup(String categoryId, Group group) async {
    await remoteDataSource.addGroup(categoryId, group);
  }

  @override
  Future<void> updateGroup(String categoryId, Group group) async {
    await remoteDataSource.updateGroup(categoryId, group);
  }

  @override
  Future<void> deleteGroup(String categoryId, String groupId) async {
    await remoteDataSource.deleteGroup(categoryId, groupId);
  }

  @override
  Future<void> enrollStudentToGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    await remoteDataSource.enrollStudentToGroup(categoryId, groupId, studentId);
  }

  @override
  Future<void> removeStudentFromGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    await remoteDataSource.removeStudentFromGroup(
      categoryId,
      groupId,
      studentId,
    );
  }
}
