import '../entities/course.dart';

/// Contrato para manejar cursos e inscripciones.
/// No depende de cómo se guarde la info (memoria, SQLite, Firebase, etc.).
abstract class CourseRepository {
  /// Crea un curso NUEVO. El repositorio genera el id internamente.
  Course createCourse({
    required String name,
    required String description,
    required String createdByUserId,
  });

  /// Lista todos los cursos.
  List<Course> listCourses();

  /// Inscribe un usuario (userId) en un curso (courseId).
  void enrollUser({
    required String courseId,
    required String userId,
  });

  /// Devuelve SOLO los ids de usuarios inscritos a un curso.
  List<String> listEnrolledUserIds(String courseId);
}
