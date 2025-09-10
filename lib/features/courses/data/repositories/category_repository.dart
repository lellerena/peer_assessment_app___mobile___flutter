import '../../domain/repositories/i_category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../../domain/models/category.dart';

class CategoryRepository implements ICategoryRepository {
  final ICategoryLocalDataSource localDataSource;

  CategoryRepository(this.localDataSource);

  @override
  Future<List<Category>> getCategories(String courseId) async =>
      await localDataSource.getCategories(courseId);

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
