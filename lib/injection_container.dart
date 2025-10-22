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
import 'features/courses/data/repositories/group_repository.dart';
import 'features/courses/data/repositories/activity_repository.dart';
import 'features/courses/data/repositories/submission_repository.dart';
import 'features/courses/data/repositories/assessment_repository.dart';
import 'features/courses/data/repositories/grade_repository.dart';
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/repositories/i_category_repository.dart';
import 'features/courses/domain/repositories/i_group_repository.dart';
import 'features/courses/domain/repositories/i_activity_repository.dart';
import 'features/courses/domain/repositories/i_submission_repository.dart';
import 'features/courses/domain/repositories/i_assessment_repository.dart';
import 'features/courses/domain/repositories/i_grade_repository.dart';
import 'features/courses/domain/usecases/course_usecase.dart';
import 'features/courses/domain/usecases/category_usecase.dart';
import 'features/courses/domain/usecases/group_usecases.dart';
import 'features/courses/domain/usecases/activity_usecase.dart';
import 'features/courses/domain/usecases/submission_usecase.dart';
import 'features/courses/domain/usecases/assessment_usecase.dart';
import 'features/courses/domain/usecases/grade_usecase.dart';
import 'features/courses/ui/controllers/course_controller.dart';
import 'features/courses/ui/controllers/group_controller.dart';
import 'features/courses/ui/controllers/submission_controller.dart';
import 'features/courses/ui/controllers/grade_controller.dart';
import 'features/auth/data/datasources/remote/i_authentication_source.dart';
import 'features/auth/data/datasources/remote/authentication_source_service_roble.dart';
import 'features/courses/data/datasources/datasources.dart';
import 'features/courses/data/datasources/i_grade_source.dart';
import 'features/courses/data/datasources/remote/remote_grade_roble_source.dart';

Future<void> init() async {
  Loggy.initLoggy(logPrinter: const PrettyPrinter(showColors: true));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put<ILocalPreferences>(LocalPreferencesSecured());

  Get.put<SharedPreferences>(sharedPreferences);

  Get.lazyPut<IAuthenticationSource>(
    () => AuthenticationSourceServiceRoble(),
    fenix: true,
  );

  Get.lazyPut<RefreshClient>(
    () => RefreshClient(http.Client(), Get.find<IAuthenticationSource>()),
    tag: 'apiClient',
    fenix: true,
  );
  Get.put<IAuthRepository>(AuthRepository(Get.find()));
  Get.put(AuthenticationUseCase(Get.find()));
  Get.put(AuthenticationController(Get.find()));

  // --- Data sources ---
  Get.lazyPut<ICourseSource>(() => RemoteCourseRobleSource(), fenix: true);
  Get.lazyPut<ICategorySource>(() => RemoteCategoryRobleSource(), fenix: true);
  Get.lazyPut<IGroupSource>(() => RemoteGroupRobleSource(), fenix: true);
  Get.lazyPut<IActivityDataSource>(() => RemoteActivityRobleDataSource());
  Get.lazyPut<ISubmissionDataSource>(() => RemoteSubmissionRobleDataSource());
  Get.lazyPut<IAssessmentSource>(() => RemoteAssessmentRobleSource());
  Get.lazyPut<IGradeSource>(() => RemoteGradeRobleSource());
  

  // --- Repositories ---
  Get.lazyPut<ICourseRepository>(
    () => CourseRepository(Get.find()),
    fenix: true,
  );
  Get.lazyPut<ICategoryRepository>(
    () => CategoryRepository(Get.find()),
    fenix: true,
  );
  Get.lazyPut<IGroupRepository>(
    () => GroupRepository(
      localDataSource: LocalGroupSource(),
      remoteDataSource: Get.find<IGroupSource>(),
    ),
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
  Get.lazyPut<IGradeRepository>(
    () => GradeRepository(Get.find<IGradeSource>()),
    fenix: true,
  );

  // --- Use cases ---
  Get.lazyPut(() => CourseUseCase(Get.find<ICourseRepository>()), fenix: true);
  Get.lazyPut(() => CategoryUseCase(Get.find<ICategoryRepository>()), fenix: true);
  Get.lazyPut(() => GetGroups(Get.find<IGroupRepository>()), fenix: true);
  Get.lazyPut(() => GetGroupById(Get.find<IGroupRepository>()), fenix: true);
  Get.lazyPut(() => GetGroupsByCategoryId(Get.find<IGroupRepository>()), fenix: true);
  Get.lazyPut(() => GetGroupsByCourseId(Get.find<IGroupRepository>()), fenix: true);
  Get.lazyPut(() => AddGroup(Get.find<IGroupRepository>()), fenix: true);
  Get.lazyPut(() => UpdateGroup(Get.find<IGroupRepository>()), fenix: true);
  Get.lazyPut(() => DeleteGroup(Get.find<IGroupRepository>()), fenix: true);
  Get.put(ActivityUseCase(Get.find<IActivityRepository>()));
  Get.put(SubmissionUseCase(Get.find<ISubmissionRepository>()));
  Get.put(AssessmentUseCase(Get.find<IAssessmentRepository>()));
  Get.put(GradeUsecase(Get.find<IGradeRepository>()));

  // --- Controllers ---
  Get.lazyPut(() => CourseController(Get.find<CourseUseCase>()), fenix: true);
  Get.lazyPut(() => GroupController(
    getGroups: Get.find<GetGroups>(),
    getGroupByIdUseCase: Get.find<GetGroupById>(),
    getGroupsByCategoryId: Get.find<GetGroupsByCategoryId>(),
    getGroupsByCourseId: Get.find<GetGroupsByCourseId>(),
    addGroup: Get.find<AddGroup>(),
    updateGroup: Get.find<UpdateGroup>(),
    deleteGroup: Get.find<DeleteGroup>(),
  ), fenix: true);
  Get.lazyPut(
    () => SubmissionController(Get.find<SubmissionUseCase>()),
    fenix: true,
  );
  Get.lazyPut(
    () => GradeController(Get.find<GradeUsecase>()),
    fenix: true,
  );
}
