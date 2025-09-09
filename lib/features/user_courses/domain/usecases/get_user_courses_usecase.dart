import '../../../courses/domain/models/course.dart';
import '../../../courses/domain/usecases/course_usecase.dart';

class GetUserCoursesUseCase {
  final CourseUseCase courses;
  GetUserCoursesUseCase(this.courses);

  Future<List<Course>> call(String userId) async {
    // Usa SIEMPRE getAll() del CourseUseCase (o alias a getCourses())
    final all = await courses.getAll();
    return all.where((c) => c.enrolledUserIds.contains(userId)).toList();
  }
}

