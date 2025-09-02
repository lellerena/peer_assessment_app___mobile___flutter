import '../contracts/auth_repository.dart';
import '../entities/user.dart';

/// Iniciar sesión
class SignIn {
  final AuthRepository repo;
  SignIn(this.repo);

  /// Devuelve el User si las credenciales son correctas; null si no.
  User? call(String email, String password) {
    return repo.signIn(email, password);
  }
}

/// Cerrar sesión
class SignOut {
  final AuthRepository repo;
  SignOut(this.repo);

  void call() {
    repo.signOut();
  }
}

/// Registrar nuevo usuario (el repo genera el id)
class Register {
  final AuthRepository repo;
  Register(this.repo);

  User call({
    required String email,
    required String name,
    required String password,
  }) {
    return repo.register(email: email, name: name, password: password);
  }
}

/// Obtener el usuario actualmente logeado (o null)
class GetCurrentUser {
  final AuthRepository repo;
  GetCurrentUser(this.repo);

  User? call() {
    return repo.currentUser;
  }
}
