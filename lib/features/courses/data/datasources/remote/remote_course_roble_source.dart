import 'package:loggy/loggy.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '/core/i_local_preferences.dart';

import '../../../domain/models/course.dart';
import '../i_course_source.dart';

class RemoteCourseRobleSource implements ICourseSource {
  // Simulating a database with an in-memory list
  // static final List<Course> _courses = [];
  final http.Client httpClient;

  final String contract = 'scheduler_51d857e7d5';
  final String baseUrl = 'roble-api.openlab.uninorte.edu.co';
  String get contractUrl => '$baseUrl/$contract';
  final String table = 'courses';

  RemoteCourseRobleSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<bool> addCourse(Course course) async {
    logInfo("Adding course to remote Roble source: ${course.name}");
    final uri = Uri.https(baseUrl, '/database/$contract/insert');

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'table': table,
      'records': [course.toJsonNoId()],
    });

    final response = await httpClient.post(uri, headers: headers, body: body);

    if (response.statusCode == 201) {
      logInfo("Course added successfully");
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];

      logError(
        "addCourse got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error('AddCourse error code ${response.statusCode}');
    }
  }

  // @override
  // Future<bool> deleteCategory(Category category) async {
  //   logInfo("Deleting category from remote source: ${category.name}");
  //   _categories.removeWhere((c) => c.id == category.id);
  //   return Future.value(true);
  // }

  @override
  Future<List<Course>> getCourses() async {
    logInfo("Getting courses from remote Roble source");

    List<Course> courses = [];

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
    });

    logInfo("Fetching courses from remote source");

    final ILocalPreferences sharedPreferences = Get.find();

    final token = await sharedPreferences.retrieveData<String>('token');
    logInfo("Using token: $token");
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("Response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      logInfo("Decoded JSON: $decodedJson");
      courses = List<Course>.from(decodedJson.map((x) => Course.fromJson(x)));
      logInfo("Fetched ${courses.length} courses from remote source");
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }

    // Return a copy to prevent direct modification of the source list
    return Future.value(List<Course>.from(courses));
  }

  @override
  Future<bool> updateCourse(Course course) async {
    logInfo("Updating course in remote roble source: ${course.name}");

    logInfo("Web service, Updating course with id ${course.id}");
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
        'idValue': course.id,
        'updates': course.toJsonNoId(),
      }),
    );

    //logInfo("update response status code ${response.statusCode}");
    //logInfo("update response body ${response.body}");
    if (response.statusCode == 200) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "UpdateCourse got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error(
        'UpdateCourse error code ${response.statusCode}: $errorMessage',
      );
    }
  }

  @override
  Future<bool> enrollUser(String courseId, String userId) async {
    logInfo("Enrolling user $userId in course $courseId");
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final uri = Uri.https(baseUrl, '/database/$contract/update');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await httpClient.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'tableName': table,
        'idColumn': '_id',
        'idValue': courseId,
        'updates': {
          '\$addToSet': {'studentIds': userId},
        },
      }),
    );

    if (response.statusCode == 200) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "EnrollUser got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error(
        'EnrollUser error code ${response.statusCode}: $errorMessage',
      );
    }
  }

  @override
  Future<List<Course>> getAll() {
    return getCourses();
  }

  @override
  Future<List<String>> getEnrolledUserIds(String courseId) {
    logInfo("Getting enrolled user IDs for course $courseId");
    return getCourses().then((courses) {
      final course = courses.firstWhere(
        (course) => course.id == courseId,
        orElse: () {
          logError("Course with id $courseId not found");
          return Course(
            id: '',
            name: 'Unknown',
            description: '',
            teacherId: '',
          );
        },
      );
      return course.studentIds;
    });
  }

  @override
  Future<List<Course>> getCoursesByUserId(String userId) async {
    logInfo("Getting courses for userId $userId from remote Roble source");

    List<Course> courses = [];

    var uri = Uri.https(baseUrl, '/database/$contract/read', {
      'tableName': table,
      'filter': jsonEncode({
        'studentIds': {
          '\$in': [userId],
        },
      }),
    });

    logInfo("Fetching courses by userId from remote source");

    final ILocalPreferences sharedPreferences = Get.find();

    final token = await sharedPreferences.retrieveData<String>('token');
    var response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("Response status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      List<dynamic> decodedJson = jsonDecode(response.body);
      courses = List<Course>.from(decodedJson.map((x) => Course.fromJson(x)));
      logInfo(
        "Fetched ${courses.length} courses for userId from remote source",
      );
    } else {
      logError("Got error code ${response.statusCode}");
      return Future.error('Error code ${response.statusCode}');
    }

    // Return a copy to prevent direct modification of the source list
    return Future.value(List<Course>.from(courses));
  }
}
