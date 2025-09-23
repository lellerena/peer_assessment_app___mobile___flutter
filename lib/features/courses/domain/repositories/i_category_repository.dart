import '../models/index.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category> getCategoryById(String id);
  Future<List<Category>> getCategoriesByCourseId(String courseId);
  Future<bool> addCategory(Category category);
  Future<bool> updateCategory(Category category);
  Future<bool> deleteCategory(Category category);

  // CRUD grupos
  Future<void> addGroup(String categoryId, Group group);
  Future<void> updateGroup(String categoryId, Group group);
  Future<void> deleteGroup(String categoryId, String groupId);
  Future<void> enrollStudentToGroup(
    String categoryId,
    String groupId,
    String studentId,
  );
  Future<void> removeStudentFromGroup(
    String categoryId,
    String groupId,
    String studentId,
  );
}
