import 'package:flutter/material.dart';
import '../../core/entities/category.dart';
import '../../core/services/in_memory_category_repository.dart';
import '../../core/usecases/category_usecases.dart';
import 'dart:math';

class CategoryCrudScreen extends StatefulWidget {
  const CategoryCrudScreen({Key? key}) : super(key: key);

  @override
  State<CategoryCrudScreen> createState() => _CategoryCrudScreenState();
}

class _CategoryCrudScreenState extends State<CategoryCrudScreen> {
  final repo = InMemoryCategoryRepository();
  late final createCategory = CreateCategory(repo);
  late final getCategories = GetCategories(repo);
  late final updateCategory = UpdateCategory(repo);
  late final deleteCategory = DeleteCategory(repo);

  final nameController = TextEditingController();
  GroupingMethod groupingMethod = GroupingMethod.random;
  int groupSize = 3;

  String? editingId;

  void _addOrUpdateCategory() {
    if (nameController.text.isEmpty) return;
    if (editingId == null) {
      final newCategory = Category(
        id: Random().nextInt(100000).toString(),
        name: nameController.text,
        groupingMethod: groupingMethod,
        groupSize: groupSize,
      );
      createCategory(newCategory);
    } else {
      final category = repo.getById(editingId!);
      if (category != null) {
        category.name = nameController.text;
        category.groupingMethod = groupingMethod;
        category.groupSize = groupSize;
        updateCategory(category);
      }
      editingId = null;
    }
    nameController.clear();
    setState(() {});
  }

  void _editCategory(Category category) {
    nameController.text = category.name;
    groupingMethod = category.groupingMethod;
    groupSize = category.groupSize;
    editingId = category.id;
    setState(() {});
  }

  void _deleteCategory(String id) {
    deleteCategory(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = getCategories();
    return Scaffold(
      appBar: AppBar(title: const Text('Categories CRUD')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            DropdownButton<GroupingMethod>(
              value: groupingMethod,
              items: GroupingMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method.toString().split('.').last),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => groupingMethod = val);
              },
            ),
            Row(
              children: [
                const Text('Group Size:'),
                Expanded(
                  child: Slider(
                    value: groupSize.toDouble(),
                    min: 2,
                    max: 10,
                    divisions: 8,
                    label: groupSize.toString(),
                    onChanged: (val) {
                      setState(() => groupSize = val.round());
                    },
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addOrUpdateCategory,
              child: Text(editingId == null ? 'Add Category' : 'Update Category'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text('Method: ${category.groupingMethod.toString().split('.').last}, Size: ${category.groupSize}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editCategory(category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCategory(category.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
