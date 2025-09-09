import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/usecases/course_usecase.dart';

class CourseController extends GetxController {
  final CourseUseCase usecase;
  CourseController(this.usecase);

  final courses = <Course>[].obs;
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCourses();
  }

  Future<void> getCourses() async {
    loading.value = true;
    courses.value = await usecase.getCourses();
    loading.value = false;
  }

  Future<void> addCourse(String name, String desc, String userId) async {
    await usecase.addCourse(
      Course(id: '', name: name, description: desc, createdByUserId: userId),
    );
    await getCourses();
  }

  Future<void> enroll(String courseId, String userId) async {
    await usecase.enrollUser(courseId, userId);
  }

  // ...
final enrolledUserIds = <String>[].obs;

Future<void> loadEnrolled(String courseId) async {
  enrolledUserIds.value = await usecase.getEnrolledUserIds(courseId);
}
// ...

}
