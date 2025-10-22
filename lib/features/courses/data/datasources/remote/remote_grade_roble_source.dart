import 'dart:convert';
import 'package:loggy/loggy.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../i_grade_source.dart';
import '/core/i_local_preferences.dart';

class RemoteGradeRobleSource implements IGradeSource {
  final http.Client httpClient;

  final String contract = 'scheduler_51d857e7d5';
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'grades';

  RemoteGradeRobleSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<List<Map<String, dynamic>>> getGradesByActivityId(String activityId) async {
    try {
      logInfo('Fetching grades for activityId: $activityId');
      
      final sharedPreferences = Get.find<ILocalPreferences>();
      final token = await sharedPreferences.retrieveData<String>('token');
      
      var uri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': table,
        'activityId': activityId,
      });

      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.body;
        final jsonData = jsonDecode(data);
        logInfo('Response status code: ${response.statusCode}');
        logDebug('Response body: $data');
        
        if (jsonData is List) {
          return List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(jsonData['data']);
        }
        return [];
      } else {
        logError('Error al obtener calificaciones por actividad: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logError('Error al obtener calificaciones por actividad: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGradesByStudentId(String studentId) async {
    try {
      logInfo('Fetching grades for studentId: $studentId');
      
      final sharedPreferences = Get.find<ILocalPreferences>();
      final token = await sharedPreferences.retrieveData<String>('token');
      
      var uri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': table,
        'studentId': studentId,
      });

      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.body;
        final jsonData = jsonDecode(data);
        logInfo('Response status code: ${response.statusCode}');
        logDebug('Response body: $data');
        
        if (jsonData is List) {
          return List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(jsonData['data']);
        }
        return [];
      } else {
        logError('Error al obtener calificaciones por estudiante: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      logError('Error al obtener calificaciones por estudiante: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getGradeById(String id) async {
    try {
      logInfo('Fetching grade by id: $id');
      
      final sharedPreferences = Get.find<ILocalPreferences>();
      final token = await sharedPreferences.retrieveData<String>('token');
      
      var uri = Uri.https(baseUrl, '/database/$contract/read', {
        'tableName': table,
        '_id': id,
      });

      final response = await httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.body;
        final jsonData = jsonDecode(data);
        logInfo('Response status code: ${response.statusCode}');
        logDebug('Response body: $data');
        
        if (jsonData is List && jsonData.isNotEmpty) {
          return jsonData.first;
        } else if (jsonData is Map<String, dynamic>) {
          return jsonData;
        }
        return null;
      } else {
        logError('Error al obtener calificación por ID: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logError('Error al obtener calificación por ID: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> createGrade(Map<String, dynamic> grade) async {
    try {
      logInfo('Creating grade: $grade');
      
      final sharedPreferences = Get.find<ILocalPreferences>();
      final token = await sharedPreferences.retrieveData<String>('token');
      
      var uri = Uri.https(baseUrl, '/database/$contract/insert');
      
      final response = await httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'tableName': table,
          'records': [grade],
        }),
      );
      
      logInfo('Response status code: ${response.statusCode}');
      logDebug('Response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.body;
        final jsonData = jsonDecode(data);
        if (jsonData is Map && jsonData.containsKey('inserted') && jsonData['inserted'].isNotEmpty) {
          return jsonData['inserted'][0];
        }
        return jsonData;
      } else {
        logError('Error al crear calificación: ${response.statusCode}');
        throw Exception('Error al crear calificación: ${response.body}');
      }
    } catch (e) {
      logError('Error al crear calificación: $e');
      throw Exception('Error al crear calificación: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateGrade(Map<String, dynamic> grade) async {
    try {
      final id = grade['_id'] ?? grade['id'];
      logInfo('Updating grade with id: $id');
      
      // Crear una copia del grade sin el _id para los updates
      final updates = Map<String, dynamic>.from(grade);
      updates.remove('_id');
      updates.remove('id');
      
      final sharedPreferences = Get.find<ILocalPreferences>();
      final token = await sharedPreferences.retrieveData<String>('token');
      
      var uri = Uri.https(baseUrl, '/database/$contract/update');
      
      final response = await httpClient.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'tableName': table,
          'idColumn': '_id',
          'idValue': id,
          'updates': updates,
        }),
      );
      
      logInfo('Response status code: ${response.statusCode}');
      logDebug('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = response.body;
        final jsonData = jsonDecode(data);
        return jsonData;
      } else {
        logError('Error al actualizar calificación: ${response.statusCode}');
        throw Exception('Error al actualizar calificación: ${response.body}');
      }
    } catch (e) {
      logError('Error al actualizar calificación: $e');
      throw Exception('Error al actualizar calificación: $e');
    }
  }

  @override
  Future<bool> deleteGrade(String id) async {
    try {
      logInfo('Deleting grade with id: $id');
      
      final sharedPreferences = Get.find<ILocalPreferences>();
      final token = await sharedPreferences.retrieveData<String>('token');
      
      var uri = Uri.https(baseUrl, '/database/$contract/delete');
      
      final response = await httpClient.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'tableName': table,
          'idColumn': '_id',
          'idValue': id,
        }),
      );
      
      logInfo('Response status code: ${response.statusCode}');
      logDebug('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        logError('Error al eliminar calificación: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      logError('Error al eliminar calificación: $e');
      return false;
    }
  }
}