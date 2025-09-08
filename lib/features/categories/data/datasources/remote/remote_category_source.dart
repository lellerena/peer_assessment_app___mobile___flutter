import 'package:loggy/loggy.dart';
import 'dart:async';
import '../../../domain/models/category.dart';
import '../i_remote_category_source.dart';

class RemoteCategorySource implements IRemoteCategorySource {
  // Simulating a database with an in-memory list
  static final List<Category> _categories = [];

  RemoteCategorySource();

  @override
  Future<bool> addCategory(Category category) async {
    logInfo("Adding category to remote source: ${category.name}");
    _categories.add(category);
    return Future.value(true);
  }

  @override
  Future<bool> deleteCategory(Category category) async {
    logInfo("Deleting category from remote source: ${category.name}");
    _categories.removeWhere((c) => c.id == category.id);
    return Future.value(true);
  }

  @override
  Future<List<Category>> getCategories() async {
    logInfo("Getting categories from remote source");
    // Return a copy to prevent direct modification of the source list
    return Future.value(List<Category>.from(_categories));
  }

  @override
  Future<bool> updateCategory(Category category) async {
    logInfo("Updating category in remote source: ${category.name}");
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      return Future.value(true);
    }
    return Future.value(false);
  }
}
