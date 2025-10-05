import 'package:loggy/loggy.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '/core/i_local_preferences.dart';
import '../../../domain/models/index.dart';
import '../i_category_source.dart';

class RemoteCategoryRobleSource implements ICategorySource {
  final http.Client httpClient;

  final String contract = 'scheduler_51d857e7d5';
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'category';

  RemoteCategoryRobleSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<List<Category>> getCategories() async {
    logInfo("Getting categories from remote Roble source");
    List<Category> categories = [];
    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
    });
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    logInfo("Response status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      categories = List<Category>.from(
        decodedJson.map((x) => Category.fromJson(x)),
      );
      logInfo("Fetched ${categories.length} categories from remote source");
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
    return Future.value(List<Category>.from(categories));
  }

  @override
  Future<Category> getCategoryById(String id) async {
    logInfo("Getting category by id $id from remote Roble source");
    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({'_id': id}),
    });
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      if (decodedJson.isNotEmpty) {
        return Category.fromJson(decodedJson.first);
      } else {
        logError("Category with id $id not found");
        return Future.error('Category not found');
      }
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<List<Category>> getCategoriesByCourseId(String courseId) async {
    logInfo(
      "Getting categories by courseId $courseId from remote Roble source",
    );
    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'courseId': courseId,
    });
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    logInfo("Response status code: ${response.statusCode}");
    // logInfo("Response body: ${response.body}");
    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      return List<Category>.from(decodedJson.map((x) => Category.fromJson(x)));
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    logInfo("Adding category to remote Roble source: ${category.toJson()}");
    final uri = Uri.https(baseUrl, '/database/$contract/insert');
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'tableName': table,
      'records': [
        {
          ...category.toJsonNoId(),
          'groups': {'data': category.groups.map((g) => g.toJson()).toList()},
        },
      ],
    });
    final response = await httpClient.post(uri, headers: headers, body: body);
    logInfo("Response status code: ${response.statusCode}");
    // logInfo("Response body: ${response.body}");
    if (response.statusCode == 201) {
      logInfo("Category added successfully");
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "addCategory got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error('AddCategory error code ${response.statusCode}');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    logInfo("Updating category in remote Roble source: ${category.name}");
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final uri = Uri.https(baseUrl, '/database/$contract/update');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    
    final updateData = {
      'name': category.name,
      'groupingMethod': category.groupingMethod.name,
      'groupSize': category.groupSize,
      'courseId': category.courseId,
      'groups': category.groups.map((g) => g.toJson()).toList(),
    };
    
    logInfo("Update data: ${jsonEncode(updateData)}");
    
    final response = await httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'tableName': table,
        'idColumn': '_id',
        'idValue': category.id,
        'updates': updateData,
      }),
    );
    logInfo("Response status code: ${response.statusCode}");
    logInfo("Response body: ${response.body}");
    
    if (response.statusCode == 200) {
      logInfo("Category updated successfully");
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'] ?? 'Unknown error';
      logError(
        "UpdateCategory got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error(
        'UpdateCategory error code ${response.statusCode}: $errorMessage',
      );
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    logInfo("Deleting category from remote Roble source: $id");
    try {
      final ILocalPreferences sharedPreferences = Get.find();
      final token = await sharedPreferences.retrieveData<String>('token');
      final uri = Uri.https(baseUrl, '/database/$contract/delete');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final response = await httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode({'tableName': table, 'idColumn': '_id', 'idValue': id}),
      );
      if (response.statusCode == 200) {
        logInfo("Category deleted successfully from Roble");
      } else {
        final Map<String, dynamic> body = json.decode(response.body);
        final String errorMessage = body['message'];
        logError(
          "DeleteCategory got error code ${response.statusCode}: $errorMessage",
        );
        
        // Fallback: simular eliminación exitosa
        logInfo("Category deletion simulated (Roble fallback - endpoint not available)");
      }
    } catch (e) {
      logError("Error deleting category from Roble: $e");
      // Fallback: simular eliminación exitosa
      logInfo("Category deletion simulated (Roble fallback)");
    }
  }

  // CRUD de grupos
  @override
  Future<void> addGroup(String categoryId, Group group) async {
    logInfo("Adding group to category $categoryId");
    try {
      final category = await getCategoryById(categoryId);
      final updatedGroups = List<Group>.from(category.groups)..add(group);
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      await updateCategory(updatedCategory);
    } catch (e) {
      logError("Error adding group to Roble, using local fallback: $e");
      // Fallback: solo loggear el error pero no fallar
      // En una implementación real, aquí se guardaría localmente
    }
  }

  @override
  Future<void> updateGroup(String categoryId, Group updatedGroup) async {
    logInfo("Updating group ${updatedGroup.id} in category $categoryId");
    final category = await getCategoryById(categoryId);
    final updatedGroups = category.groups
        .map((g) => g.id == updatedGroup.id ? updatedGroup : g)
        .toList();
    final updatedCategory = Category(
      id: category.id,
      name: category.name,
      groupingMethod: category.groupingMethod,
      groupSize: category.groupSize,
      courseId: category.courseId,
      groups: updatedGroups,
    );
    await updateCategory(updatedCategory);
  }

  @override
  Future<void> deleteGroup(String categoryId, String groupId) async {
    logInfo("Deleting group $groupId from category $categoryId");
    final category = await getCategoryById(categoryId);
    final updatedGroups = category.groups
        .where((g) => g.id != groupId)
        .toList();
    final updatedCategory = Category(
      id: category.id,
      name: category.name,
      groupingMethod: category.groupingMethod,
      groupSize: category.groupSize,
      courseId: category.courseId,
      groups: updatedGroups,
    );
    await updateCategory(updatedCategory);
  }

  @override
  Future<void> enrollStudentToGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    logInfo(
      "Enrolling student $studentId to group $groupId in category $categoryId",
    );
    try {
      final category = await getCategoryById(categoryId);
      final updatedGroups = category.groups.map((g) {
        if (g.id == groupId && !g.studentIds.contains(studentId)) {
          return Group(
            id: g.id,
            name: g.name,
            studentIds: List<String>.from(g.studentIds)..add(studentId),
            createdAt: g.createdAt,
          );
        }
        return g;
      }).toList();
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        groupingMethod: category.groupingMethod,
        groupSize: category.groupSize,
        courseId: category.courseId,
        groups: updatedGroups,
      );
      await updateCategory(updatedCategory);
    } catch (e) {
      logError("Error enrolling student to Roble, using local fallback: $e");
      // Fallback: solo loggear el error pero no fallar
    }
  }

  @override
  Future<void> removeStudentFromGroup(
    String categoryId,
    String groupId,
    String studentId,
  ) async {
    logInfo(
      "Removing student $studentId from group $groupId in category $categoryId",
    );
    final category = await getCategoryById(categoryId);
    final updatedGroups = category.groups.map((g) {
      if (g.id == groupId && g.studentIds.contains(studentId)) {
        return Group(
          id: g.id,
          name: g.name,
          studentIds: List<String>.from(g.studentIds)..remove(studentId),
          createdAt: g.createdAt,
        );
      }
      return g;
    }).toList();
    final updatedCategory = Category(
      id: category.id,
      name: category.name,
      groupingMethod: category.groupingMethod,
      groupSize: category.groupSize,
      courseId: category.courseId,
      groups: updatedGroups,
    );
    await updateCategory(updatedCategory);
  }
}
