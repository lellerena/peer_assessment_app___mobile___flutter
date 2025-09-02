import '../entities/user.dart';

/// Define QUÉ puede hacer la capa de datos para autenticación.
/// No dice CÓMO se hace (eso vendrá en la implementación).
abstract class AuthRepository {
  /// Usuario que está con sesión iniciada (o null si nadie).
  User? get currentUser;

  /// Inicia sesión. Devuelve el usuario si las credenciales son correctas; null si no.
  User? signIn(String email, String password);

  /// Cierra la sesión.
  void signOut();

  /// Registra un usuario NUEVO (el repo genera el id y devuelve el User creado).
  User register({
    required String email,
    required String name,
    required String password,
  });

  /// Para validar si un email ya está tomado.
  bool existsByEmail(String email);
    /// Busca un usuario por su id (o null si no existe).
  User? findById(String id);

  /// Busca un usuario por su email (o null si no existe).
  User? findByEmail(String email);
  
}
