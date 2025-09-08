import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/category.dart';
import '../../domain/use_case/category_usecase.dart';

class CategoryController extends GetxController {
  final RxList<Category> _categories = <Category>[].obs;
  final CategoryUseCase categoryUseCase;

  CategoryController(this.categoryUseCase);

  List<Category> get categories => _categories;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  getCategories() async {
    logInfo("Getting categories");
    _categories.value = await categoryUseCase.getCategories();
  }

  addCategory(Category category) async {
    logInfo("Adding category");
    await categoryUseCase.addCategory(category);
    getCategories();
  }

  updateCategory(Category category) async {
    logInfo("Updating category");
    await categoryUseCase.updateCategory(category);
    getCategories();
  }

  deleteCategory(Category category) async {
    logInfo("Deleting category");
    await categoryUseCase.deleteCategory(category);
    getCategories();
  }
}
