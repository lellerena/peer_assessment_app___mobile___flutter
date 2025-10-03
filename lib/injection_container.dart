import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import 'package:get/get.dart';

import 'core/i_local_preferences.dart';
import 'core/refresh_client.dart';
import 'core/local_preferences_secured.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/domain/usecase/auth_usecase.dart';
import 'features/auth/ui/controller/auth_controller.dart';

import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/data/repositories/category_repository.dart';
import 'features/courses/data/repositories/activity_repository.dart';
import 'features/courses/data/repositories/submission_repository.dart';
import 'features/courses/data/repositories/assessment_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/repositories/i_category_repository.dart';
import 'features/courses/domain/repositories/i_activity_repository.dart';
import 'features/courses/domain/repositories/i_submission_repository.dart';
import 'features/courses/domain/repositories/i_assessment_repository.dart';
import 'features/courses/domain/usecases/course_usecase.dart';
import 'features/courses/domain/usecases/category_usecase.dart';
import 'features/courses/domain/usecases/activity_usecase.dart';
import 'features/courses/domain/usecases/submission_usecase.dart';
import 'features/courses/domain/usecases/assessment_usecase.dart';
import 'features/courses/ui/controllers/course_controller.dart';
import 'features/courses/ui/controllers/submission_controller.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/datasources/remote/authentication_source_service_roble.dart';
import 'features/courses/data/datasources/datasources.dart';

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
  Get.lazyPut<ICategorySource>(() => RemoteCategoryRobleSource());
  Get.lazyPut<IActivityDataSource>(() => RemoteActivityRobleDataSource());
  Get.lazyPut<ISubmissionDataSource>(() => RemoteSubmissionRobleDataSource());
  Get.lazyPut<IAssessmentSource>(() => RemoteAssessmentRobleSource());

  // --- Repositories ---
  Get.lazyPut<ICourseRepository>(
    () => CourseRepository(Get.find()),
    fenix: true,
  );
  Get.lazyPut<ICategoryRepository>(
    () => CategoryRepository(Get.find()),
    fenix: true,
  );
  Get.lazyPut<IActivityRepository>(
    () => ActivityRepository(Get.find()),
    fenix: true,
  );
  Get.lazyPut<ISubmissionRepository>(
    () => SubmissionRepository(Get.find()),
    fenix: true,
  );
  Get.lazyPut<IAssessmentRepository>(
    () => AssessmentRepository(Get.find()),
    fenix: true,
  );

  // --- Use cases ---
  Get.lazyPut(() => CourseUseCase(Get.find<ICourseRepository>()), fenix: true);
  Get.put(CategoryUseCase(Get.find<ICategoryRepository>()));
  Get.put(ActivityUseCase(Get.find<IActivityRepository>()));
  Get.put(SubmissionUseCase(Get.find<ISubmissionRepository>()));
  Get.put(AssessmentUseCase(Get.find<IAssessmentRepository>()));

  // --- Controllers ---
  Get.lazyPut(() => CourseController(Get.find<CourseUseCase>()), fenix: true);
  Get.lazyPut(
    () => SubmissionController(Get.find<SubmissionUseCase>()),
    fenix: true,
  );
}
