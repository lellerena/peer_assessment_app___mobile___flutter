import '../contracts/auth_repository.dart';
import 'in_memory_auth_repository.dart';

// 🔌 Punto ÚNICO de cambio de almacenamiento.
// Hoy:
final AuthRepository authRepository = InMemoryAuthRepository();

// Mañana, si usas Firebase/SQLite/Hive, solo cambias esta línea:
// final AuthRepository authRepository = FirebaseAuthRepository();
// final AuthRepository authRepository = SqliteAuthRepository();
