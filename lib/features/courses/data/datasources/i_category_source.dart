import '../../domain/models/index.dart';

abstract class ICategorySource {
  Future<List<Category>> getCategories();
  Future<Category> getCategoryById(String id);
  Future<List<Category>> getCategoriesByCourseId(String courseId);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);

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
