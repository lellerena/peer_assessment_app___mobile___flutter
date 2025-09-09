import 'dart:async';
import '../../domain/models/user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  // Demo: usuarios en memoria
  final List<User> _users = const [
    User(id: 'u1', name: 'Jhon', email: 'admin@example.com'),
    User(id: 'u2', name: 'Ana',  email: 'ana@example.com'),
  ];

  User? _current;

  @override
  Future<User?> signIn(String email, String password) async {
    // DEMO: contraseña ignorada (no hagas esto en producción)
    final u = _users.firstWhere(
      (x) => x.email.toLowerCase() == email.toLowerCase(),
      orElse: () => const User(id: '', name: '', email: ''),
    );
    _current = u.id.isEmpty ? null : u;
    return _current;
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }

  @override
  Future<User?> currentUser() async => _current;

  @override
  Future<List<User>> getUsersByIds(List<String> ids) async {
    return _users.where((u) => ids.contains(u.id)).toList();
  }
}
