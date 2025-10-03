import 'package:loggy/loggy.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '/core/i_local_preferences.dart';

import '../../../domain/models/submission.dart';
import '../i_submission_source.dart';

class RemoteSubmissionRobleDataSource implements ISubmissionDataSource {
  final http.Client httpClient;

  final String contract = 'scheduler_51d857e7d5';
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'submissions';

  RemoteSubmissionRobleDataSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<List<Submission>> getSubmissionsByActivityId(String activityId) async {
    logInfo('Fetching submissions for activityId: $activityId');

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'activityId': activityId,
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
      final submissions = List<Submission>.from(
        decodedJson.map((json) => Submission.fromJson(json)),
      );
      logInfo(
        "Retrieved ${submissions.length} submissions for activityId: $activityId",
      );
      return submissions;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<List<Submission>> getSubmissionsByStudentId(String studentId) async {
    logInfo('Fetching submissions for studentId: $studentId');

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({'studentId': studentId}),
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

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      final submissions = List<Submission>.from(
        decodedJson.map((json) => Submission.fromJson(json)),
      );
      return submissions;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<List<Submission>> getSubmissionsByGroupId(String groupId) async {
    logInfo('Fetching submissions for groupId: $groupId');

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({'groupId': groupId}),
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

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      final submissions = List<Submission>.from(
        decodedJson.map((json) => Submission.fromJson(json)),
      );
      return submissions;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<List<Submission>> getSubmissionsByCourseId(String courseId) async {
    logInfo('Fetching submissions for courseId: $courseId');

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({'courseId': courseId}),
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

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      final submissions = List<Submission>.from(
        decodedJson.map((json) => Submission.fromJson(json)),
      );
      return submissions;
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> addSubmission(Submission submission) async {
    logInfo("Adding submission to remote Roble source: ${submission.toJson()}");
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'tableName': table,
      'records': [submission.toJsonNoId()],
    });

    final response = await httpClient.post(uri, headers: headers, body: body);
    logInfo("Response status code: ${response.statusCode}");
    logDebug("Response body: ${response.body}");

    if (response.statusCode == 201) {
      logInfo("Submission added successfully");
      logInfo("Response body: ${response.body}");
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError("Failed to add submission. Error: $errorMessage");
      return Future.error('AddSubmission error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> updateSubmission(Submission submission) async {
    logInfo(
      "Updating submission in remote roble source: ${submission.toJson()}",
    );

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final uri = Uri.https(baseUrl, '/database/$contract/update');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Preparar las actualizaciones excluyendo el campo id
    final updates = Map<String, dynamic>.from(submission.toJsonNoId());

    // Asegurarse de que no existe un campo 'id' o 'undefined'
    updates.remove('id');
    updates.remove('undefined');

    final response = await httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'tableName': table,
        'idField': '_id',
        'idValue': submission.id,
        'updates': updates,
      }),
    );

    logInfo("Response status code: ${response.statusCode}");
    logDebug("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError("Failed to update submission. Error: $errorMessage");
      return Future.error('UpdateSubmission error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> deleteSubmission(String submissionId) async {
    logInfo("Deleting submission with ID: $submissionId");

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
        'idField': '_id',
        'idValue': submissionId,
      }),
    );

    if (response.statusCode == 200) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError("Failed to delete submission. Error: $errorMessage");
      return Future.error('DeleteSubmission error code ${response.statusCode}');
    }
  }

  @override
  Future<Submission?> getSubmissionById(String submissionId) async {
    logInfo("Getting submission with ID: $submissionId");

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({'_id': submissionId}),
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

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      if (decodedJson.isEmpty) {
        return null;
      }
      return Submission.fromJson(decodedJson.first);
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }
  }
}
