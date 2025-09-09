import '../models/course.dart';
import '../repositories/i_course_repository.dart';

class CourseUseCase {
  final ICourseRepository repo;
  CourseUseCase(this.repo);
  Future<List<Course>> getAll() => repo.getAll();
  Future<List<Course>> getCourses() => repo.getCourses();
  Future<bool> addCourse(Course c) => repo.addCourse(c);
  Future<bool> enrollUser(String courseId, String userId) =>
      repo.enrollUser(courseId, userId);
  Future<List<String>> getEnrolledUserIds(String courseId) =>
      repo.getEnrolledUserIds(courseId);
}
