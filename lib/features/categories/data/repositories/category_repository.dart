import '../../domain/repositories/i_category_repository.dart';
import '../datasources/i_remote_category_source.dart';
import '../../domain/models/category.dart';

class CategoryRepository implements ICategoryRepository {
  late IRemoteCategorySource categorySource;

  CategoryRepository(this.categorySource);

  @override
  Future<List<Category>> getCategories() async =>
      await categorySource.getCategories();

  @override
  Future<bool> addCategory(Category category) async =>
      await categorySource.addCategory(category);

  @override
  Future<bool> updateCategory(Category category) async =>
      await categorySource.updateCategory(category);

  @override
  Future<bool> deleteCategory(Category category) async =>
      await categorySource.deleteCategory(category);
}
