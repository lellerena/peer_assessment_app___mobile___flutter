import 'package:get/get.dart';
import '../../../courses/domain/models/course.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../../domain/usecases/get_user_courses_usecase.dart';

class UserCoursesController extends GetxController {
  final GetUserCoursesUseCase usecase;
  final AuthController auth;

  UserCoursesController(this.usecase, this.auth);

  final loading = false.obs;
  final courses = <Course>[].obs;

  Future<void> load() async {
    loading.value = true;
    final user = auth.currentUser.value;
    courses.value = user == null ? <Course>[] : await usecase(user.id);
    loading.value = false;
  }
}
