import 'package:get/get.dart';
import '../../domain/models/user.dart';
import '../../domain/usecase/auth_usecase.dart';

class AuthController extends GetxController {
  final AuthUseCase usecase;
  AuthController(this.usecase);

  final Rxn<User> currentUser = Rxn<User>();
  final loading = false.obs;

  Future<bool> signIn(String email, String pass) async {
    loading.value = true;
    final u = await usecase.signIn(email, pass);
    currentUser.value = u;
    loading.value = false;
    return u != null;
  }

  Future<void> signOut() async {
    await usecase.signOut();
    currentUser.value = null;
  }

  Future<List<User>> getUsersByIds(List<String> ids) =>
      usecase.getUsersByIds(ids);
}
