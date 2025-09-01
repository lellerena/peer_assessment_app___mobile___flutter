import '../entities/category.dart';
import '../contracts/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;
  GetCategories(this.repository);

  List<Category> call() => repository.getAll();
}

class GetCategoryById {
  final CategoryRepository repository;
  GetCategoryById(this.repository);

  Category? call(String id) => repository.getById(id);
}

class CreateCategory {
  final CategoryRepository repository;
  CreateCategory(this.repository);

  void call(Category category) => repository.create(category);
}

class UpdateCategory {
  final CategoryRepository repository;
  UpdateCategory(this.repository);

  void call(Category category) => repository.update(category);
}

class DeleteCategory {
  final CategoryRepository repository;
  DeleteCategory(this.repository);

  void call(String id) => repository.delete(id);
}
