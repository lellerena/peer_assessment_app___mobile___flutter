import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'package:get/get.dart';
import 'package:peer_assessment_app___mobile___flutter/features/courses/data/datasources/i_course_source.dart';

import 'core/app_theme.dart';
import 'core/i_local_preferences.dart';
import 'core/refresh_client.dart';
import 'core/local_preferences_secured.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/usecase/auth_usecase.dart';
import 'features/auth/ui/controller/auth_controller.dart';

import 'features/courses/data/datasources/course_local_data_source.dart';
import 'features/courses/data/datasources/category_local_data_source.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/data/repositories/category_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/repositories/i_category_repository.dart';
import 'features/courses/domain/usecases/course_usecase.dart';
import 'features/courses/domain/usecases/category_usecase.dart';
import 'features/courses/ui/controllers/course_controller.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/datasources/remote/authentication_source_service_roble.dart';
import 'features/courses/data/datasources/remote/remote_course_roble_source.dart';

Future<void> init() async {
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put<ILocalPreferences>(LocalPreferencesSecured());

  Get.lazyPut<SharedPreferences>(() => sharedPreferences);

  Get.lazyPut<IAuthenticationSource>(
    () => AuthenticationSourceServiceRoble(),
    fenix: true,
  );

  Get.put<http.Client>(
    RefreshClient(http.Client(), Get.find<IAuthenticationSource>()),
    tag: 'apiClient',
    permanent: true,
  );
  Get.put<IAuthRepository>(AuthRepository(Get.find()));
  Get.put(AuthenticationUseCase(Get.find()));
  Get.put(AuthenticationController(Get.find()));

  // --- Data sources ---
  Get.lazyPut<ICourseSource>(() => RemoteCourseRobleSource(), fenix: true);
  Get.lazyPut<ICategoryLocalDataSource>(
    () => CategoryLocalDataSource(Get.find()),
  );

  // --- Repositories ---
  Get.lazyPut<ICourseRepository>(
    () => CourseRepository(Get.find()),
    fenix: true,
  );
  Get.lazyPut<ICategoryRepository>(
    () => CategoryRepository(Get.find()),
    fenix: true,
  );

  // --- Use cases ---
  Get.lazyPut(() => CourseUseCase(Get.find<ICourseRepository>()), fenix: true);
  Get.put(CategoryUseCase(Get.find<ICategoryRepository>()));

  // --- Controllers ---
  Get.lazyPut(() => CourseController(Get.find<CourseUseCase>()), fenix: true);
}
