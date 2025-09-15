import '../../../domain/models/user.dart';

abstract class IAuthenticationSource {
  Future<bool> login(String username, String password);

  Future<bool> signUp(User user);

  Future<bool> logOut();

  Future<bool> validate(String email, String validationCode);

  Future<bool> refreshToken();

  Future<bool> forgotPassword(String email);

  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  );

  Future<bool> verifyToken();
}
