import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/usecase/auth_usecase.dart';
import 'features/auth/ui/controller/auth_controller.dart';
import 'features/courses/data/datasources/course_local_data_source.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/usecases/course_usecase.dart';
import 'features/courses/ui/controllers/course_controller.dart';

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut<SharedPreferences>(() => sharedPreferences);

  // --- Data sources ---
  Get.lazyPut<IAuthLocalDataSource>(() => AuthLocalDataSource(Get.find()));
  Get.lazyPut<ICourseLocalDataSource>(() => CourseLocalDataSource(Get.find()));

  // --- Repositories ---
  Get.lazyPut<IAuthRepository>(() => AuthRepository(Get.find()));
  Get.lazyPut<ICourseRepository>(() => CourseRepository(Get.find()));

  // --- Use cases ---
  Get.lazyPut(() => AuthUseCase(Get.find<IAuthRepository>()));
  Get.lazyPut(() => CourseUseCase(Get.find<ICourseRepository>()));

  // --- Controllers ---
  Get.lazyPut(() => AuthController(Get.find<AuthUseCase>()));
  Get.lazyPut(() => CourseController(Get.find<CourseUseCase>(), Get.find<AuthController>()));
}
