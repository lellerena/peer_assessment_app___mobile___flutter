import '../entities/category.dart';
import '../contracts/category_repository.dart';

class InMemoryCategoryRepository implements CategoryRepository {
  final List<Category> _categories = [];

  @override
  List<Category> getAll() => List.unmodifiable(_categories);

  @override
    Category? getById(String id) {
      try {
        return _categories.firstWhere((c) => c.id == id);
      } catch (e) {
        return null;
      }
    }

  @override
  void create(Category category) {
    _categories.add(category);
  }

  @override
  void update(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  @override
  void delete(String id) {
    _categories.removeWhere((c) => c.id == id);
  }
}
