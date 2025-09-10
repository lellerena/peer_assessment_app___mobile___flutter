import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut<SharedPreferences>(() => sharedPreferences);

  // Data sources
  Get.lazyPut<IAuthLocalDataSource>(() => AuthLocalDataSource(Get.find()));

  // Repositories
  Get.lazyPut<IAuthRepository>(() => AuthRepository(Get.find()));
}
