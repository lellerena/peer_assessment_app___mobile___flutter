import '../contracts/auth_repository.dart';
import '../entities/user.dart';

class InMemoryAuthRepository implements AuthRepository {
   @override
  User? findById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  User? findByEmail(String email) {
    try {
      return _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }


  // "Base de datos" temporal: una lista en memoria
  final List<User> _users = [
    User(
      id: '1',
      email: 'admin@example.com',
      name: 'Admin',
      password: '123456', // solo para demo
    ),
  ];

  User? _current; // quién está logeado ahora (si hay alguien)

  @override
  User? get currentUser => _current;

  // Generador simple de IDs únicos (suficiente para demo)
  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  User? signIn(String email, String password) {
    try {
      final u = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      );
      _current = u;
      return u; // login ok
    } catch (_) {
      return null; // credenciales inválidas
    }
  }

  @override
  void signOut() {
    _current = null; // cerrar sesión
  }

  @override
  User register({
    required String email,
    required String name,
    required String password,
  }) {
    // no permitir correos duplicados
    if (existsByEmail(email)) {
      throw Exception('Email ya registrado');
    }

    final user = User(
      id: _newId(),        // <-- el repo genera el id
      email: email,
      name: name,
      password: password,  // demo: en real, usa hash
    );

    _users.add(user);
    return user;
  }

  @override
  bool existsByEmail(String email) {
    return _users.any((u) => u.email.toLowerCase() == email.toLowerCase());
  }
}
