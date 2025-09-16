import '/features/courses/data/datasources/i_course_source.dart';

import '../../domain/models/course.dart';
import '../../domain/repositories/i_course_repository.dart';

class CourseRepository implements ICourseRepository {
  final ICourseSource remoteDataSource;

  CourseRepository(this.remoteDataSource);

  @override
  Future<List<Course>> getAll() => remoteDataSource.getAll();

  @override
  Future<List<Course>> getCourses() => remoteDataSource.getCourses();

  @override
  Future<bool> addCourse(Course c) => remoteDataSource.addCourse(c);

  @override
  Future<bool> enrollUser(String courseId, String userId) =>
      remoteDataSource.enrollUser(courseId, userId);

  @override
  Future<List<String>> getEnrolledUserIds(String courseId) =>
      remoteDataSource.getEnrolledUserIds(courseId);
}
