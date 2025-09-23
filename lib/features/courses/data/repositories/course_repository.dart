import '/features/courses/data/datasources/i_course_source.dart';

import '../../domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';

class CourseRepository implements ICourseRepository {
  final ICourseSource localDataSource;

  CourseRepository(this.localDataSource);

  @override
  Future<List<Course>> getAll() => localDataSource.getAll();

  @override
  Future<List<Course>> getCourses() => localDataSource.getCourses();

  @override
  Future<bool> addCourse(Course c) => localDataSource.addCourse(c);

  @override
  Future<bool> enrollUser(String courseId, String userId) =>
      localDataSource.enrollUser(courseId, userId);

  @override
  Future<List<String>> getEnrolledUserIds(String courseId) =>
      localDataSource.getEnrolledUserIds(courseId);

  @override
  Future<bool> updateCourse(Course course) =>
      localDataSource.updateCourse(course);
  @override
  Future<List<Course>> getCoursesByUserId(String userId) =>
      localDataSource.getCoursesByUserId(userId);
  @override
  Future<List<Course>> getCoursesByTeacherId(String teacherId) {
    return localDataSource.getCoursesByTeacherId(teacherId);
  }
}
