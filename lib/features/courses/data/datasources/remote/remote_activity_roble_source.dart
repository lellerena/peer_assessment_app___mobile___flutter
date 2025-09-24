import 'package:loggy/loggy.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '/core/i_local_preferences.dart';

import '../../../domain/models/activity.dart';
import '../i_activity_source.dart';

class RemoteActivityRobleDataSource implements IActivityDataSource {
  final http.Client httpClient;

  final String contract = 'scheduler_51d857e7d5';
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'activities';

  RemoteActivityRobleDataSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<List<Activity>> getActivitiesByCourseId(String courseId) async {
    logInfo('Fetching activities for courseId: $courseId');

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'courseId': courseId,
    });

    logDebug('GET $uri');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    logInfo("Response status code: ${response.statusCode}");
    logDebug("Response body: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      final activities = List<Activity>.from(
        decodedJson.map(
          (x) => Activity.fromJson({
            'id': x['_id'],
            'title': x['title'],
            'description': x['description'],
            'date': x['date'],
            'courseId': x['courseId'],
            'categoryId': x['categoryId'],
          }),
        ),
      );
      logInfo(
        "Fetched ${activities.length} activities for courseId from remote source",
      );
      return activities;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> addActivity(Activity activity) async {
    logInfo("Adding activity to remote Roble source: ${activity.toJson()}");
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'tableName': table,
      'records': [activity.toJsonNoId()],
    });

    final response = await httpClient.post(uri, headers: headers, body: body);
    logInfo("Response status code: ${response.statusCode}");
    logDebug("Response body: ${response.body}");

    if (response.statusCode == 201) {
      logInfo("Activity added successfully");
      logInfo("Response body: ${response.body}");
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];

      logError(
        "addActivity got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error('AddActivity error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> updateActivity(Activity activity) async {
    logInfo("Updating activity in remote roble source: ${activity.id}");

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final uri = Uri.https(baseUrl, '/database/$contract/update');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'tableName': table,
        'idColumn': '_id',
        'idValue': activity.id,
        'updates': activity.toJsonNoId(),
      }),
    );

    if (response.statusCode == 200) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "UpdateActivity got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error(
        'UpdateActivity error code ${response.statusCode}: $errorMessage',
      );
    }
  }

  @override
  Future<bool> deleteActivity(String activityId) async {
    logInfo("Deleting activity with ID: $activityId");

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final uri = Uri.https(baseUrl, '/database/$contract/delete');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await httpClient.delete(
      uri,
      headers: headers,
      body: jsonEncode({
        'tableName': table,
        'idColumn': '_id',
        'idValue': activityId,
      }),
    );

    if (response.statusCode == 200) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "DeleteActivity got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error(
        'DeleteActivity error code ${response.statusCode}: $errorMessage',
      );
    }
  }

  @override
  Future<Activity?> getActivityById(String activityId) async {
    logInfo("Getting activity with ID: $activityId");

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({'_id': activityId}),
    });

    logDebug('GET $uri');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      if (decodedJson.isEmpty) {
        logWarning("No activity found with ID: $activityId");
        return null;
      }
      return Activity.fromJson(decodedJson.first);
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<List<Activity>> getActivitiesByCategoryId(String categoryId) async {
    logInfo('Fetching activities for categoryId: $categoryId');

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({'categoryId': categoryId}),
    });

    logDebug('GET $uri');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      final activities = List<Activity>.from(
        decodedJson.map((x) => Activity.fromJson(x)),
      );
      logInfo(
        "Fetched ${activities.length} activities for categoryId from remote source",
      );
      return activities;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  // Helper method to get all activities
  Future<List<Activity>> getAllActivities() async {
    logInfo("Getting all activities from remote Roble source");

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
    });

    logInfo("Fetching activities from remote source");

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("Response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      final activities = List<Activity>.from(
        decodedJson.map((x) => Activity.fromJson(x)),
      );
      logInfo("Fetched ${activities.length} activities from remote source");
      return activities;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }
}
