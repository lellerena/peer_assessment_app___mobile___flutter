import '../models/user.dart';

abstract class IAuthRepository {
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  Future<User?> currentUser();
  Future<List<User>> getUsersByIds(List<String> ids); // útil para EnrolledUsers
}
