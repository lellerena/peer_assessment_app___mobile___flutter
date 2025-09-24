import 'package:loggy/loggy.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../../domain/models/course.dart';
import '../i_course_source.dart';

class LocalCourseSource implements ICourseSource {
  // Simulating a database with an in-memory list
  static List<Course> _courses = [];
  final SharedPreferences _prefs = Get.find<SharedPreferences>();
  static const String _coursesKey = 'local_courses';

  LocalCourseSource() {
    _initializeCourses();
  }

  Future<void> _initializeCourses() async {
    logInfo("Initializing local courses");

    // Try to load from SharedPreferences first
    final savedCoursesJson = _prefs.getString(_coursesKey);

    if (savedCoursesJson != null) {
      logInfo("Loading courses from SharedPreferences");
      final List<dynamic> jsonList = json.decode(savedCoursesJson);
      _courses = jsonList.map((json) => Course.fromJson(json)).toList();
    } else {
      logInfo("Loading courses from assets");
      // If no saved courses, load from assets
      try {
        final jsonString = await rootBundle.loadString(
          'assets/data/courses.json',
        );
        final List<dynamic> jsonList = json.decode(jsonString);
        _courses = jsonList.map((json) => Course.fromJson(json)).toList();
        await _saveCoursesToPrefs();
      } catch (e) {
        logError("Error loading courses from assets: $e");
        _courses = [];
      }
    }

    logInfo("Initialized with ${_courses.length} courses");
  }

  Future<void> _saveCoursesToPrefs() async {
    final coursesJson = json.encode(_courses.map((c) => c.toJson()).toList());

    await _prefs.setString(_coursesKey, coursesJson);
    logInfo("Saved ${_courses.length} courses to SharedPreferences");
  }

  @override
  Future<bool> addCourse(Course course) async {
    logInfo("Adding course to local source: ${course.name}");

    try {
      // Generate a new ID if not provided
      final newCourse = Course(
        id: course.id.isEmpty
            ? 'local_${DateTime.now().millisecondsSinceEpoch}'
            : course.id,
        name: course.name,
        description: course.description,
        categoryIds: course.categoryIds,
        teacherId: course.teacherId,
        studentIds: course.studentIds,
      );

      _courses.add(newCourse);
      await _saveCoursesToPrefs();

      logInfo("Course added successfully");
      return Future.value(true);
    } catch (e) {
      logError("Error adding course: $e");
      return Future.error('AddCourse error: $e');
    }
  }

  @override
  Future<List<Course>> getCourses() async {
    logInfo("Getting courses from local source");

    try {
      // Ensure courses are loaded
      if (_courses.isEmpty) {
        await _initializeCourses();
      }

      logInfo("Fetched ${_courses.length} courses from local source");

      // Return a copy to prevent direct modification of the source list
      return Future.value(List<Course>.from(_courses));
    } catch (e) {
      logError("Error getting courses: $e");
      return Future.error('Error getting courses: $e');
    }
  }

  @override
  Future<bool> updateCourse(Course course) async {
    logInfo("Updating course in local source: ${course.name}");

    try {
      final courseIndex = _courses.indexWhere((c) => c.id == course.id);

      if (courseIndex != -1) {
        _courses[courseIndex] = course;
        await _saveCoursesToPrefs();

        logInfo("Course updated successfully");
        return Future.value(true);
      } else {
        logError("Course with id ${course.id} not found");
        return Future.error('Course not found');
      }
    } catch (e) {
      logError("Error updating course: $e");
      return Future.error('UpdateCourse error: $e');
    }
  }

  @override
  Future<bool> enrollUser(String courseId, String userId) async {
    logInfo("Enrolling user $userId in course $courseId");

    try {
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);

      if (courseIndex != -1) {
        final course = _courses[courseIndex];

        // Check if user is already enrolled
        if (!course.studentIds.contains(userId)) {
          final updatedStudentIds = List<String>.from(course.studentIds)
            ..add(userId);

          _courses[courseIndex] = Course(
            id: course.id,
            name: course.name,
            description: course.description,
            categoryIds: course.categoryIds,
            teacherId: course.teacherId,
            studentIds: updatedStudentIds,
          );

          await _saveCoursesToPrefs();
          logInfo("User enrolled successfully");
          return Future.value(true);
        } else {
          logInfo("User $userId is already enrolled in course $courseId");
          return Future.value(true);
        }
      } else {
        logError("Course with id $courseId not found");
        return Future.error('Course not found');
      }
    } catch (e) {
      logError("Error enrolling user: $e");
      return Future.error('EnrollUser error: $e');
    }
  }

  @override
  Future<List<Course>> getAll() {
    return getCourses();
  }

  @override
  Future<List<String>> getEnrolledUserIds(String courseId) async {
    logInfo("Getting enrolled user IDs for course $courseId");

    try {
      final courses = await getCourses();
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

      return Future.value(course.studentIds);
    } catch (e) {
      logError("Error getting enrolled user IDs: $e");
      return Future.error('Error getting enrolled user IDs: $e');
    }
  }

  @override
  Future<List<Course>> getCoursesByUserId(String userId) async {
    logInfo("Getting courses for userId $userId from local source");

    try {
      final allCourses = await getCourses();
      final userCourses = allCourses
          .where((course) => course.studentIds.contains(userId))
          .toList();

      logInfo(
        "Fetched ${userCourses.length} courses for userId from local source",
      );

      // Return a copy to prevent direct modification of the source list
      return Future.value(List<Course>.from(userCourses));
    } catch (e) {
      logError("Error getting courses by user ID: $e");
      return Future.error('Error getting courses by user ID: $e');
    }
  }

  @override
  Future<List<Course>> getCoursesByTeacherId(String teacherId) async {
    logInfo("Getting courses for teacherId $teacherId from local source");

    try {
      final allCourses = await getCourses();
      final teacherCourses = allCourses
          .where((course) => course.teacherId == teacherId)
          .toList();

      logInfo(
        "Fetched ${teacherCourses.length} courses for teacherId from local source",
      );

      // Return a copy to prevent direct modification of the source list
      return Future.value(List<Course>.from(teacherCourses));
    } catch (e) {
      logError("Error getting courses by teacher ID: $e");
      return Future.error('Error getting courses by teacher ID: $e');
    }
  }

  // Additional utility methods for local operations

  Future<bool> deleteCourse(String courseId) async {
    logInfo("Deleting course $courseId from local source");

    try {
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);

      if (courseIndex != -1) {
        _courses.removeAt(courseIndex);
        await _saveCoursesToPrefs();

        logInfo("Course deleted successfully");
        return Future.value(true);
      } else {
        logError("Course with id $courseId not found");
        return Future.error('Course not found');
      }
    } catch (e) {
      logError("Error deleting course: $e");
      return Future.error('DeleteCourse error: $e');
    }
  }

  Future<bool> unenrollUser(String courseId, String userId) async {
    logInfo("Unenrolling user $userId from course $courseId");

    try {
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);

      if (courseIndex != -1) {
        final course = _courses[courseIndex];
        final updatedStudentIds = List<String>.from(course.studentIds)
          ..remove(userId);

        _courses[courseIndex] = Course(
          id: course.id,
          name: course.name,
          description: course.description,
          categoryIds: course.categoryIds,
          teacherId: course.teacherId,
          studentIds: updatedStudentIds,
        );

        await _saveCoursesToPrefs();
        logInfo("User unenrolled successfully");
        return Future.value(true);
      } else {
        logError("Course with id $courseId not found");
        return Future.error('Course not found');
      }
    } catch (e) {
      logError("Error unenrolling user: $e");
      return Future.error('UnenrollUser error: $e');
    }
  }

  Future<void> clearAllCourses() async {
    logInfo("Clearing all courses from local source");

    try {
      _courses.clear();
      await _prefs.remove(_coursesKey);
      logInfo("All courses cleared successfully");
    } catch (e) {
      logError("Error clearing courses: $e");
    }
  }

  Future<void> resetToDefault() async {
    logInfo("Resetting courses to default from assets");

    try {
      await clearAllCourses();
      await _initializeCourses();
      logInfo("Courses reset to default successfully");
    } catch (e) {
      logError("Error resetting courses: $e");
    }
  }
}
