import '../models/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> getCourses();
  Future<bool> addCourse(Course c);
  Future<List<Course>> getAll() => getCourses();
  Future<bool> enrollUser(String courseId, String userId);
  Future<List<String>> getEnrolledUserIds(String courseId);
  Future<bool> updateCourse(Course course);
  Future<List<Course>> getCoursesByUserId(String userId);
  Future<List<Course>> getCoursesByTeacherId(String teacherId);
}
