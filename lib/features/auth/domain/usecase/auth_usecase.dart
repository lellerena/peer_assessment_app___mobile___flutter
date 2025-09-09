import '../models/user.dart';
import '../repositories/i_auth_repository.dart';

class AuthUseCase {
  final IAuthRepository repo;
  AuthUseCase(this.repo);

  Future<User?> signIn(String email, String password) => repo.signIn(email, password);
  Future<void> signOut() => repo.signOut();
  Future<User?> currentUser() => repo.currentUser();
  Future<List<User>> getUsersByIds(List<String> ids) => repo.getUsersByIds(ids);
}
