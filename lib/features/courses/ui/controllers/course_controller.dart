import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/usecases/course_usecase.dart';
import '../../../../../core/i_local_preferences.dart';

class CourseController extends GetxController {
  final CourseUseCase usecase;
  CourseController(this.usecase);

  final allCourses = <Course>[].obs;
  final teacherCourses = <Course>[].obs;
  final loading = false.obs;
  final ILocalPreferences sharedPreferences = Get.find();

  @override
  void onInit() {
    super.onInit();
    getAllCourses();
    getTeacherCourses();
  }

  Future<void> refreshCourses() async {
    await getAllCourses();
    await getTeacherCourses();
  }

  @override
  void onClose() {
    super.onClose();
    allCourses.clear();
    teacherCourses.clear();
    loading.value = false;
    enrolledUserIds.clear();
  }

  Future<void> getAllCourses() async {
    loading.value = true;
    allCourses.value = await usecase.getAll();
    loading.value = false;
  }

  Future<void> getTeacherCourses() async {
    final teacherId = await sharedPreferences.retrieveData<String>('userId');
    if (teacherId == null) return;
    loading.value = true;
    final all = await usecase.getAll();
    teacherCourses.value = all.where((c) => c.teacherId == teacherId).toList();
    loading.value = false;
  }

  Future<void> addCourse(String name, String desc) async {
    final teacherId = await sharedPreferences.retrieveData<String>('userId');
    if (teacherId == null) return;
    await usecase.addCourse(
      Course(
        id: '',
        name: name,
        description: desc,
        categoryIds: [],
        teacherId: teacherId,
      ),
    );
    await getTeacherCourses();
  }

  Future<void> enroll(String courseId) async {
    final userId = await sharedPreferences.retrieveData<String>('userId');
    if (userId == null) return;
    await usecase.enrollUser(courseId, userId);
    await getAllCourses(); // Recarga para actualizar el estado del botón
  }

  final enrolledUserIds = <String>[].obs;

  Future<void> loadEnrolled(String courseId) async {
    enrolledUserIds.value = await usecase.getEnrolledUserIds(courseId);
  }
}
