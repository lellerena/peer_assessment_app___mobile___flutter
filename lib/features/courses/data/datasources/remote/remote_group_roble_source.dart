import 'package:loggy/loggy.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '/core/i_local_preferences.dart';
import '../../../domain/models/group.dart';
import '../i_group_source.dart';

class RemoteGroupRobleSource implements IGroupSource {
  final http.Client httpClient;

  final String contract = 'scheduler_51d857e7d5';
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'groups';

  RemoteGroupRobleSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<List<Group>> getGroups() async {
    logInfo("Getting groups from remote Roble source");
    List<Group> groups = [];
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
      groups = List<Group>.from(
        decodedJson.map((x) => Group.fromJson(x)),
      );
      logInfo("Fetched ${groups.length} groups from remote source");
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
    return Future.value(List<Group>.from(groups));
  }

  @override
  Future<Group> getGroupById(String id) async {
    logInfo("Getting group by id from remote Roble source: $id");
    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      '_id': id,
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
      if (decodedJson.isNotEmpty) {
        return Group.fromJson(decodedJson.first);
      } else {
        logError("Group with id $id not found");
        return Future.error('Group with id $id not found');
      }
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<List<Group>> getGroupsByCategoryId(String categoryId) async {
    logInfo(
      "Getting groups by categoryId $categoryId from remote Roble source",
    );
    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'categoryIds': categoryId, // Corregido: categoryIds en lugar de categoryId
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
      return List<Group>.from(decodedJson.map((x) => Group.fromJson(x)));
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<List<Group>> getGroupsByCourseId(String courseId) async {
    logInfo(
      "Getting groups by courseId $courseId from remote Roble source",
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
    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      return List<Group>.from(decodedJson.map((x) => Group.fromJson(x)));
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<void> addGroup(Group group) async {
    logInfo("Adding group to remote Roble source: ${group.toJson()}");
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'tableName': table,
      'records': [group.toJsonNoId()],
    });

    logInfo("Sending insert request: $body");

    final response = await httpClient.post(uri, headers: headers, body: body);

    logInfo("Response status code: ${response.statusCode}");
    logInfo("Response body: ${response.body}");

    if (response.statusCode == 201) {
      logInfo("Group added successfully");
      // Parsear respuesta para obtener información de inserción
      try {
        final responseData = json.decode(response.body);
        logInfo("Inserted records: ${responseData['inserted']}");
        if (responseData['skipped'] != null && responseData['skipped'].isNotEmpty) {
          logWarning("Skipped records: ${responseData['skipped']}");
        }
      } catch (e) {
        logWarning("Could not parse response body: $e");
      }
    } else {
      logError("addGroup got error code ${response.statusCode}");
      logError("Response body: ${response.body}");
      return Future.error('AddGroup error code ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    logInfo("Updating group in remote Roble source: ${group.toJson()}");
    final uri = Uri.https(baseUrl, '/database/$contract/update');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Preparar los updates según la documentación de Roble
    final updates = {
      'name': group.name,
      'categoryIds': group.categoryId, // Corregido: categoryIds en lugar de categoryId
      'courseId': group.courseId,
      'studentIds': group.studentIds, // Nombre correcto de la columna
    };

    final body = jsonEncode({
      'tableName': table,
      'idColumn': '_id',
      'idValue': group.id,
      'updates': updates,
    });

    logInfo("Sending update request: $body");

    final response = await httpClient.put(uri, headers: headers, body: body);

    logInfo("Response status code: ${response.statusCode}");
    logInfo("Response body: ${response.body}");

    if (response.statusCode == 200) {
      logInfo("Group updated successfully");
    } else {
      logError("updateGroup got error code ${response.statusCode}");
      logError("Response body: ${response.body}");
      return Future.error('UpdateGroup error code ${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    logInfo("Deleting group from remote Roble source: $id");
    final uri = Uri.https(baseUrl, '/database/$contract/delete');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'tableName': table,
      'idColumn': '_id',
      'idValue': id,
    });

    logInfo("Sending delete request: $body");

    final response = await httpClient.delete(uri, headers: headers, body: body);

    logInfo("Response status code: ${response.statusCode}");
    logInfo("Response body: ${response.body}");

    if (response.statusCode == 200) {
      logInfo("Group deleted successfully");
    } else {
      logError("deleteGroup got error code ${response.statusCode}");
      logError("Response body: ${response.body}");
      return Future.error('DeleteGroup error code ${response.statusCode}: ${response.body}');
    }
  }
}
