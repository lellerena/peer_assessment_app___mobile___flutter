import '../models/user.dart';
import '../models/user_role.dart';
import '../repositories/i_auth_repository.dart';

class AuthenticationUseCase {
  final IAuthRepository _repository;

  AuthenticationUseCase(this._repository);

  Future<bool> login(String email, String password) async =>
      await _repository.login(email, password);

  Future<bool> signUp(String email, String password) async =>
      await _repository.signUp(
        User(
          name: email,
          email: email,
          role: UserRole.student,
          password: password,
        ),
      );

  Future<bool> validate(String email, String validationCode) async =>
      await _repository.validate(email, validationCode);

  Future<bool> logOut() async => await _repository.logOut();

  Future<bool> validateToken() async => await _repository.validateToken();

  Future<void> forgotPassword(String email) async =>
      _repository.forgotPassword(email);

  //
}
