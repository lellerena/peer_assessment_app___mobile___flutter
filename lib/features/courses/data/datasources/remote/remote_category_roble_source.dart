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
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        logError('Timeout al obtener categorías');
        throw TimeoutException('La petición tardó demasiado tiempo', const Duration(seconds: 10));
      },
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
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        logError('Timeout al obtener categoría por ID');
        throw TimeoutException('La petición tardó demasiado tiempo', const Duration(seconds: 10));
      },
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
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        logError('Timeout al obtener categorías por curso');
        throw TimeoutException('La petición tardó demasiado tiempo', const Duration(seconds: 10));
      },
    );
    logInfo("Response status code: ${response.statusCode}");
    // logInfo("Response body: ${response.body}");
    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      List<Category> categories = List<Category>.from(decodedJson.map((x) => Category.fromJson(x)));
      
      // Cargar todos los grupos del curso en una sola consulta para optimizar rendimiento
      if (categories.isNotEmpty) {
        try {
          logInfo("Loading all groups for course $courseId in single query");
          final allGroups = await _getAllGroupsForCourse(courseId);
          
          // Agrupar los grupos por categoryId
          final Map<String, List<Group>> groupsByCategory = {};
          for (final group in allGroups) {
            groupsByCategory.putIfAbsent(group.categoryId, () => []).add(group);
          }
          
          // Actualizar cada categoría con sus grupos correspondientes
          for (int i = 0; i < categories.length; i++) {
            final categoryGroups = groupsByCategory[categories[i].id] ?? [];
            if (categoryGroups.isNotEmpty) {
              logInfo("Found ${categoryGroups.length} groups for category ${categories[i].id}");
              categories[i] = Category(
                id: categories[i].id,
                name: categories[i].name,
                groupingMethod: categories[i].groupingMethod,
                groupSize: categories[i].groupSize,
                courseId: categories[i].courseId,
                groups: categoryGroups,
              );
            }
          }
        } catch (e) {
          logError("Error loading groups for course: $e");
          // Si falla la carga, mantener los grupos del campo groups de la categoría
        }
      }
      
      return categories;
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
    try {
      final ILocalPreferences sharedPreferences = Get.find();
      final token = await sharedPreferences.retrieveData<String>('token');
      final uri = Uri.https(baseUrl, '/database/$contract/update');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      // Estructura plana para evitar problemas de serialización
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
      
      if (response.statusCode == 200) {
        logInfo("Category updated successfully");
      } else {
        final Map<String, dynamic> body = json.decode(response.body);
        final String errorMessage = body['message'] ?? 'Unknown error';
        logError(
          "UpdateCategory got error code ${response.statusCode}: $errorMessage",
        );
        // No lanzar error, permitir fallback local
        logInfo("Category update failed, will use local fallback");
      }
    } catch (e) {
      logError("Error updating category in Roble: $e");
      // No lanzar error, permitir fallback local
      logInfo("Category update failed, will use local fallback");
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    logInfo("Deleting category from remote Roble source: $id");
    try {
      // 1. Primero eliminar todos los grupos asociados a esta categoría
      await _deleteGroupsByCategoryId(id);
      
      // 2. Luego eliminar la categoría
      final ILocalPreferences sharedPreferences = Get.find();
      final token = await sharedPreferences.retrieveData<String>('token');
      final uri = Uri.https(baseUrl, '/database/$contract/delete');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      final body = jsonEncode({
        'tableName': table,
        'idColumn': '_id',
        'idValue': id,
      });
      
      logInfo("Sending category delete request: $body");
      
      final response = await httpClient.delete(uri, headers: headers, body: body);
      
      logInfo("Category delete response status code: ${response.statusCode}");
      logInfo("Category delete response body: ${response.body}");
      
      if (response.statusCode == 200) {
        logInfo("Category deleted successfully from Roble");
      } else {
        logError("DeleteCategory got error code ${response.statusCode}");
        logError("Response body: ${response.body}");
        throw Exception('Failed to delete category from Roble: ${response.statusCode}');
      }
    } catch (e) {
      logError("Error deleting category from Roble: $e");
      // Lanzar el error para que el usuario sepa que la eliminación falló
      rethrow;
    }
  }

  // Método privado para eliminar todos los grupos de una categoría
  Future<void> _deleteGroupsByCategoryId(String categoryId) async {
    logInfo("Deleting all groups for category: $categoryId");
    try {
      // Obtener todos los grupos de todos los cursos y filtrar por categoryId
      // Esto evita problemas si la categoría ya no existe
      final uri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': 'groups',
        'categoryIds': categoryId,
      });
      
      final ILocalPreferences sharedPreferences = Get.find();
      final token = await sharedPreferences.retrieveData<String>('token');
      final headers = {
        'Authorization': 'Bearer $token',
      };
      
      logInfo("Getting groups for category: $categoryId");
      
      final response = await httpClient.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = jsonDecode(response.body);
        final categoryGroups = decodedJson.map((json) => Group.fromJson(json)).toList();
        
        logInfo("Found ${categoryGroups.length} groups to delete for category $categoryId");
        
        // Eliminar cada grupo individualmente
        for (final group in categoryGroups) {
          try {
            await _deleteGroupFromGroupsTable(group.id);
            logInfo("Group ${group.name} deleted successfully");
          } catch (e) {
            logError("Error deleting group ${group.name}: $e");
            // Continuar con los demás grupos aunque uno falle
          }
        }
        
        logInfo("All groups deleted for category $categoryId");
      } else {
        logError("Error getting groups for category $categoryId: ${response.statusCode}");
        logError("Response body: ${response.body}");
      }
    } catch (e) {
      logError("Error deleting groups for category $categoryId: $e");
      // No lanzar error, permitir continuar con la eliminación de la categoría
    }
  }

  // CRUD de grupos
  @override
  Future<void> addGroup(String categoryId, Group group) async {
    logInfo("Adding group to category $categoryId");
    logInfo("Group data: ${group.toJson()}");
    logInfo("Group studentIds: ${group.studentIds}");
    logInfo("Group studentIds type: ${group.studentIds.runtimeType}");
    try {
      // 1. Guardar el grupo en la tabla groups de Roble
      await _addGroupToGroupsTable(group);
      
      // 2. Actualizar la categoría para incluir el grupo
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
      logInfo("Group added successfully to Roble");
    } catch (e) {
      logError("Error adding group to Roble: $e");
      // No lanzar error, permitir fallback local
      logInfo("Group addition failed, will use local fallback");
    }
  }

  // Método privado para obtener todos los grupos de un curso en una sola consulta
  Future<List<Group>> _getAllGroupsForCourse(String courseId) async {
    logInfo("Getting all groups for course: $courseId");
    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'groups',
      'courseId': courseId,
    });
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    logInfo("All groups response status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      List<Group> groups = List<Group>.from(decodedJson.map((x) => Group.fromJson(x)));
      logInfo("Found ${groups.length} total groups for course $courseId");
      return groups;
    } else {
      logError("Got error code ${response.statusCode} when reading all groups");
      return [];
    }
  }

  // Método privado para agregar grupo a la tabla groups
  Future<void> _addGroupToGroupsTable(Group group) async {
    logInfo("Adding group to groups table: ${group.toJson()}");
    final uri = Uri.https(baseUrl, '/database/$contract/insert');
    
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'tableName': 'groups',
      'records': [group.toJsonNoId()],
    });

    logInfo("Sending group insert request: $body");

    final response = await httpClient.post(uri, headers: headers, body: body);

    logInfo("Group insert response status code: ${response.statusCode}");
    logInfo("Group insert response body: ${response.body}");

    if (response.statusCode == 201) {
      logInfo("Group added successfully to groups table");
      // Parsear respuesta para obtener información de inserción
      try {
        final responseData = json.decode(response.body);
        logInfo("Inserted group records: ${responseData['inserted']}");
        if (responseData['skipped'] != null && responseData['skipped'].isNotEmpty) {
          logWarning("Skipped group records: ${responseData['skipped']}");
        }
      } catch (e) {
        logWarning("Could not parse group insert response body: $e");
      }
    } else {
      logError("addGroupToGroupsTable got error code ${response.statusCode}");
      logError("Response body: ${response.body}");
      throw Exception('Failed to add group to groups table: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateGroup(String categoryId, Group updatedGroup) async {
    logInfo("Updating group ${updatedGroup.id} in category $categoryId");
    try {
      // Actualizar el grupo en la tabla groups de Roble
      await _updateGroupInGroupsTable(updatedGroup);
      logInfo("Group updated successfully in Roble");
    } catch (e) {
      logError("Error updating group in Roble: $e");
      logInfo("Group update failed, will use local fallback");
    }
  }

  // Método privado para obtener un grupo desde la tabla groups independiente
  Future<Group> _getGroupFromGroupsTable(String groupId) async {
    logInfo("Getting group from groups table: $groupId");
    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': 'groups',
      '_id': groupId,
    });
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    logInfo("Get group response status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      if (decodedJson.isNotEmpty) {
        return Group.fromJson(decodedJson.first);
      } else {
        throw Exception('Group with id $groupId not found in groups table');
      }
    } else {
      logError("Got error code ${response.statusCode} when reading group");
      throw Exception('Failed to get group from groups table: ${response.statusCode}');
    }
  }

  // Método privado para actualizar grupo en la tabla groups
  Future<void> _updateGroupInGroupsTable(Group group) async {
    logInfo("Updating group in groups table: ${group.toJson()}");
    logInfo("Group studentIds: ${group.studentIds}");
    logInfo("Group studentIds type: ${group.studentIds.runtimeType}");
    
    try {
      // Primero intentar obtener el grupo para verificar si existe
      await _getGroupFromGroupsTable(group.id);
      logInfo("Group exists, proceeding with update");
    } catch (e) {
      logInfo("Group does not exist in groups table, creating it first");
      await _addGroupToGroupsTable(group);
      return;
    }
    
    final uri = Uri.https(baseUrl, '/database/$contract/update');
    
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final updates = {
      'name': group.name,
      'categoryIds': group.categoryId, // Corregido: categoryIds en lugar de categoryId
      'courseId': group.courseId,
      'studentIds': group.studentIds, // Nombre correcto de la columna
    };

    final body = jsonEncode({
      'tableName': 'groups',
      'idColumn': '_id',
      'idValue': group.id,
      'updates': updates,
    });

    logInfo("Sending group update request: $body");

    final response = await httpClient.put(uri, headers: headers, body: body);

    logInfo("Group update response status code: ${response.statusCode}");
    logInfo("Group update response body: ${response.body}");

    if (response.statusCode == 200) {
      logInfo("Group updated successfully in groups table");
    } else {
      logError("updateGroupInGroupsTable got error code ${response.statusCode}");
      logError("Response body: ${response.body}");
      throw Exception('Failed to update group in groups table: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteGroup(String categoryId, String groupId) async {
    logInfo("Deleting group $groupId from category $categoryId");
    try {
      // Eliminar el grupo de la tabla groups de Roble
      await _deleteGroupFromGroupsTable(groupId);
      logInfo("Group deleted successfully from Roble");
    } catch (e) {
      logError("Error deleting group from Roble: $e");
      logInfo("Group deletion failed, will use local fallback");
    }
  }

  // Método privado para eliminar grupo de la tabla groups
  Future<void> _deleteGroupFromGroupsTable(String groupId) async {
    logInfo("Deleting group from groups table: $groupId");
    final uri = Uri.https(baseUrl, '/database/$contract/delete');
    
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'tableName': 'groups',
      'idColumn': '_id',
      'idValue': groupId,
    });

    logInfo("Sending group delete request: $body");

    final response = await httpClient.delete(uri, headers: headers, body: body);

    logInfo("Group delete response status code: ${response.statusCode}");
    logInfo("Group delete response body: ${response.body}");

    if (response.statusCode == 200) {
      logInfo("Group deleted successfully from groups table");
    } else {
      logError("deleteGroupFromGroupsTable got error code ${response.statusCode}");
      logError("Response body: ${response.body}");
      throw Exception('Failed to delete group from groups table: ${response.statusCode}');
    }
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
      // Obtener el grupo actual desde la tabla groups independiente
      final group = await _getGroupFromGroupsTable(groupId);
      
      // Verificar que el estudiante no esté ya en el grupo
      if (group.studentIds.contains(studentId)) {
        logInfo("Student $studentId is already in group $groupId");
        return;
      }
      
      // Crear el grupo actualizado con el nuevo estudiante
      final updatedGroup = Group(
        id: group.id,
        name: group.name,
        categoryId: group.categoryId,
        courseId: group.courseId,
        studentIds: List<String>.from(group.studentIds)..add(studentId),
        createdAt: group.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // Actualizar el grupo en la tabla groups de Roble
      await _updateGroupInGroupsTable(updatedGroup);
      
      logInfo("Student enrolled successfully to Roble");
    } catch (e) {
      logError("Error enrolling student to Roble: $e");
      // No lanzar error, permitir fallback local
      logInfo("Student enrollment failed, will use local fallback");
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
    try {
      // Obtener el grupo actual desde la tabla groups independiente
      final group = await _getGroupFromGroupsTable(groupId);
      
      // Verificar que el estudiante esté en el grupo
      if (!group.studentIds.contains(studentId)) {
        logInfo("Student $studentId is not in group $groupId");
        return;
      }
      
      // Crear el grupo actualizado sin el estudiante
      final updatedGroup = Group(
        id: group.id,
        name: group.name,
        categoryId: group.categoryId,
        courseId: group.courseId,
        studentIds: group.studentIds.where((id) => id != studentId).toList(),
        createdAt: group.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // Actualizar el grupo en la tabla groups de Roble
      await _updateGroupInGroupsTable(updatedGroup);
      
      logInfo("Student removed successfully from Roble");
    } catch (e) {
      logError("Error removing student from Roble: $e");
      // No lanzar error, permitir fallback local
      logInfo("Student removal failed, will use local fallback");
    }
  }
}
