import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/category.dart';

abstract class ICategoryLocalDataSource {
  Future<List<Category>> getCategories(String courseId);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId);
}

class CategoryLocalDataSource implements ICategoryLocalDataSource {
  final SharedPreferences _prefs;
  List<Category> _categories = [];
  static const String _categoriesKey = 'categories';

  CategoryLocalDataSource(this._prefs) {
    _init();
  }

  Future<void> _init() async {
    try {
      final jsonString = _prefs.getString(_categoriesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _categories = jsonList.map((json) => Category.fromJson(json)).toList();
        print("Loaded ${_categories.length} categories from local storage");
      } else {
        // NO cargar desde assets automáticamente - empezar con lista vacía
        print("No local data found, starting with empty categories list");
        _categories = [];
        await _saveToPrefs();
      }
    } catch (e) {
      print("Error initializing categories: $e");
      _categories = [];
    }
  }

  Future<void> _saveToPrefs() async {
    final List<Map<String, dynamic>> jsonList =
        _categories.map((c) => c.toJson()).toList();
    await _prefs.setString(_categoriesKey, json.encode(jsonList));
  }

  // Método para cargar datos iniciales desde assets (solo si es necesario)
  Future<void> loadInitialDataFromAssets() async {
    try {
      final initialJsonString =
          await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> jsonList = json.decode(initialJsonString);
      _categories = jsonList.map((json) => Category.fromJson(json)).toList();
      await _saveToPrefs();
      print("Loaded initial data from assets: ${_categories.length} categories");
    } catch (e) {
      print("Could not load initial data from assets: $e");
    }
  }

  // Método para limpiar completamente el almacenamiento local
  Future<void> clearAllData() async {
    try {
      _categories.clear();
      await _prefs.remove(_categoriesKey);
      print("All local data cleared");
    } catch (e) {
      print("Error clearing data: $e");
    }
  }

  @override
  Future<List<Category>> getCategories(String courseId) async {
    try {
      await _init();
      return _categories.where((c) => c.courseId == courseId).toList();
    } catch (e) {
      print("Error getting categories for course $courseId: $e");
      return [];
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    try {
      await _init();
      _categories.add(category);
      await _saveToPrefs();
    } catch (e) {
      print("Error adding category: $e");
      throw Exception("Failed to add category: $e");
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      await _init();
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        await _saveToPrefs();
      } else {
        throw Exception("Category not found");
      }
    } catch (e) {
      print("Error updating category: $e");
      throw Exception("Failed to update category: $e");
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _init();
      _categories.removeWhere((c) => c.id == categoryId);
      await _saveToPrefs();
    } catch (e) {
      print("Error deleting category: $e");
      throw Exception("Failed to delete category: $e");
    }
  }
}
