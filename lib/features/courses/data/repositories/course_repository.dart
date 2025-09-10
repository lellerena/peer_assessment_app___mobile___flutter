
import 'dart:async';
import '../../domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';

class CourseRepository implements ICourseRepository {
  final List<Course> _courses = [];
  final Map<String, Set<String>> _enrollments = {};

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Future<List<Course>> getCourses() async => List.unmodifiable(_courses);

   @override
  Future<List<Course>> getAll() => getCourses();

  @override
  Future<bool> addCourse(Course c) async {
    final course = Course(
      id: c.id.isEmpty ? _newId() : c.id,
      name: c.name,
      description: c.description,
      createdByUserId: c.createdByUserId,
      enrolledUserIds: const [],
    );
    _courses.add(course);
    _enrollments[course.id] = <String>{};
    return true;
  }

  @override
  Future<bool> enrollUser(String courseId, String userId) async {
    final set = _enrollments[courseId];
    if (set == null) return false;
    set.add(userId);
    return true;
  }

  @override
  Future<List<String>> getEnrolledUserIds(String courseId) async {
    final set = _enrollments[courseId];
    return set == null ? const [] : List.unmodifiable(set);
  }
}
