import '../../domain/models/course.dart';

abstract class ICourseSource {
  Future<List<Course>> getAll();

  Future<List<Course>> getCourses();

  Future<bool> addCourse(Course c);

  Future<bool> enrollUser(String courseId, String userId);

  Future<List<String>> getEnrolledUserIds(String courseId);
}
