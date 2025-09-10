import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/course.dart';

abstract class ICourseLocalDataSource {
  Future<List<Course>> getAll();
  Future<List<Course>> getCourses();
  Future<bool> addCourse(Course c);
  Future<bool> enrollUser(String courseId, String userId);
  Future<List<String>> getEnrolledUserIds(String courseId);
}

class CourseLocalDataSource implements ICourseLocalDataSource {
  final SharedPreferences _prefs;
  List<Course> _courses = [];

  CourseLocalDataSource(this._prefs) {
    _init();
  }

  Future<void> _init() async {
    final jsonString = await rootBundle.loadString('assets/data/courses.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _courses = jsonList.map((json) => Course.fromJson(json)).toList();
    await _saveCoursesToPrefs();
  }

  Future<void> _loadCoursesFromPrefs() async {
    final coursesJson = _prefs.getString('courses');
    if (coursesJson != null) {
      final List<dynamic> jsonList = json.decode(coursesJson);
      _courses = jsonList.map((json) => Course.fromJson(json)).toList();
    }
  }

  Future<void> _saveCoursesToPrefs() async {
    final coursesJson = json.encode(_courses.map((c) => c.toJson()).toList());
    await _prefs.setString('courses', coursesJson);
  }

  @override
  Future<List<Course>> getAll() async {
    await _loadCoursesFromPrefs();
    return _courses;
  }

  @override
  Future<List<Course>> getCourses() async {
    await _loadCoursesFromPrefs();
    return _courses;
  }

  @override
  Future<bool> addCourse(Course c) async {
    await _loadCoursesFromPrefs();
    _courses.add(c);
    await _saveCoursesToPrefs();
    return true;
  }

  @override
  Future<bool> enrollUser(String courseId, String userId) async {
    await _loadCoursesFromPrefs();
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      _courses[courseIndex].studentIds.add(userId);
      await _saveCoursesToPrefs();
      return true;
    }
    return false;
  }

  @override
  Future<List<String>> getEnrolledUserIds(String courseId) async {
    await _loadCoursesFromPrefs();
    final course = _courses.firstWhere((c) => c.id == courseId);
    return course.studentIds;
  }
}
