import 'package:get/get.dart';
import '../../domain/models/user.dart';
import '../../domain/usecase/auth_usecase.dart';
import '../../../../core/services/local_storage_service.dart';

class AuthController extends GetxController {
  final AuthUseCase usecase;
  final LocalStorageService _localStorageService = LocalStorageService();

  AuthController(this.usecase);

  final Rxn<User> currentUser = Rxn<User>();
  final loading = false.obs;
  bool rememberMe = false; // Flag para recordar sesión

  Future<bool> signIn(String email, String pass) async {
    loading.value = true;
    final u = await usecase.signIn(email, pass);
    currentUser.value = u;
    loading.value = false;

    if (u != null) {
      if (rememberMe) {
        await _localStorageService.saveCredentials(email, pass);
      } else {
        await _localStorageService.clearCredentials();
      }
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await usecase.signOut();
    currentUser.value = null;
    await _localStorageService.clearCredentials();
  }

  Future<Map<String, String>?> loadSavedCredentials() async {
    return await _localStorageService.getCredentials();
  }

  Future<void> setRememberMe(bool value) async {
    rememberMe = value;
  }

  Future<bool> hasSavedCredentials() async {
    final creds = await _localStorageService.getCredentials();
    return creds != null;
  }

  Future<List<User>> getUsersByIds(List<String> ids) =>
      usecase.getUsersByIds(ids);
}
