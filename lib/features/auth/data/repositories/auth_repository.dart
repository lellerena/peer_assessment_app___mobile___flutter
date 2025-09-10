import '../../domain/models/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource localDataSource;

  AuthRepository(this.localDataSource);

  @override
  Future<User?> signIn(String email, String password) async {
    return localDataSource.signIn(email, password);
  }

  @override
  Future<void> signOut() async {
    return localDataSource.signOut();
  }

  @override
  Future<User?> currentUser() async {
    return localDataSource.currentUser();
  }

  @override
  Future<List<User>> getUsersByIds(List<String> ids) async {
    return localDataSource.getUsersByIds(ids);
  }
}
