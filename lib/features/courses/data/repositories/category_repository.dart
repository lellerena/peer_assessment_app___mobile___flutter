import '/features/courses/data/datasources/i_category_source.dart';

import '../../domain/repositories/i_category_repository.dart';
import '../../domain/models/category.dart';

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
}
