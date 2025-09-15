import '../models/user.dart';

abstract class IAuthRepository {
  Future<bool> login(String email, String password);

  Future<bool> signUp(User user);

  Future<bool> logOut();

  Future<bool> validate(String email, String validationCode);

  Future<bool> validateToken();

  Future<void> forgotPassword(String email);
}
