import '../../domain/models/category.dart';

abstract class IRemoteCategorySource {
  Future<List<Category>> getCategories();
  Future<bool> addCategory(Category category);
  Future<bool> updateCategory(Category category);
  Future<bool> deleteCategory(Category category);
}
