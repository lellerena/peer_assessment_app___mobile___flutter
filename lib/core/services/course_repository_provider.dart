import '../contracts/course_repository.dart';
import 'in_memory_course_repository.dart';

// Hoy usamos la implementación en memoria:
final CourseRepository courseRepository = InMemoryCourseRepository();

// Mañana, si cambias a SQLite/Firebase, reemplazas SOLO esta línea.
// final CourseRepository courseRepository = SqliteCourseRepository();
// final CourseRepository courseRepository = FirebaseCourseRepository();
