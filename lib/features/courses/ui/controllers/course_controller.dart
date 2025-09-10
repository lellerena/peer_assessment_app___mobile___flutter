import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/usecases/course_usecase.dart';

class CourseController extends GetxController {
  CourseController(this._useCase);
  final CourseUseCase _useCase;

  // Estado
  final loading = false.obs;
  final courses = <Course>[].obs;        // todos
  final myCourses = <Course>[].obs;      // creados por el usuario
  final enrolledUserIds = <String>[].obs;

  Future<void> loadAll() async {
    loading.value = true;
    final list = await _useCase.getCourses();
    courses.assignAll(list);
    loading.value = false;
  }

  Future<void> loadMyCourses(String userId) async {
    await loadAll();
    myCourses.assignAll(courses.where((c) => c.createdByUserId == userId));
  }

  Future<bool> addCourse(String name, String description, String createdByUserId) async {
    loading.value = true;
    final ok = await _useCase.addCourse(
      Course(
        id: '', // el repo genera el id
        name: name,
        description: description,
        createdByUserId: createdByUserId,
        enrolledUserIds: const [],
      ),
    );
    if (ok) {
      await loadAll();
      await loadMyCourses(createdByUserId);
    }
    loading.value = false;
    return ok;
  }

  Future<void> loadEnrolled(String courseId) async {
    final ids = await _useCase.getEnrolledUserIds(courseId);
    enrolledUserIds.assignAll(ids);
  }

  Future<bool> enroll(String courseId, String userId) async {
    final ok = await _useCase.enrollUser(courseId, userId);
    if (ok) {
      await loadEnrolled(courseId);
    }
    return ok;
  }
}
