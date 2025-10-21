import '/features/courses/data/datasources/i_course_source.dart';

import '../../domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';

class CourseRepository implements ICourseRepository {
  final ICourseSource dataSource;

  CourseRepository(this.dataSource);

  @override
  Future<List<Course>> getAll() => dataSource.getAll();

  @override
  Future<List<Course>> getCourses() => dataSource.getCourses();

  @override
  Future<bool> addCourse(Course c) => dataSource.addCourse(c);

  @override
  Future<bool> enrollUser(String courseId, String userId) =>
      dataSource.enrollUser(courseId, userId);

  @override
  Future<List<String>> getEnrolledUserIds(String courseId) =>
      dataSource.getEnrolledUserIds(courseId);

  @override
  Future<bool> updateCourse(Course course) =>
      dataSource.updateCourse(course);
  @override
  Future<List<Course>> getCoursesByUserId(String userId) =>
      dataSource.getCoursesByUserId(userId);
  @override
  Future<List<Course>> getCoursesByTeacherId(String teacherId) {
    return dataSource.getCoursesByTeacherId(teacherId);
  }
}
