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

  @override
  void onInit() {
    super.onInit();
    // Carga inicial
    load();
    // Si cambia el usuario logueado, recarga
    ever(auth.currentUser, (_) => load());
  }

  Future<void> load() async {
    try {
      loading.value = true;
      final user = auth.currentUser.value;
      courses.assignAll(
        user == null ? const <Course>[] : await usecase(user.id),
      );
    } catch (e, st) {
      Get.log('UserCoursesController.load ERROR: $e\n$st');
      courses.clear();
    } finally {
      loading.value = false;
    }
  }
}
