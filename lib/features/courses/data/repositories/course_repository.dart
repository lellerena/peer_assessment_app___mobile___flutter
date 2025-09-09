import '../contracts/course_repository.dart';
import '../entities/course.dart';

class InMemoryCourseRepository implements CourseRepository {
  // Lista con todos los cursos creados
  final List<Course> _courses = [];

  // Relación curso ↔ usuarios inscritos (ids)
  // clave: courseId  →  valor: conjunto de userIds
  final Map<String, Set<String>> _enrollments = {};

  // Genera ids únicos simples (suficiente para demo)
  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Course createCourse({
    required String name,
    required String description,
    required String createdByUserId,
  }) {
    final course = Course(
      id: _newId(),                // ← el repo genera el id
      name: name,
      description: description,
      createdByUserId: createdByUserId,
    );
    _courses.add(course);
    _enrollments.putIfAbsent(course.id, () => <String>{});
    return course;
  }

  @override
  List<Course> listCourses() {
    // Devolvemos una copia inmodificable para proteger el estado interno
    return List.unmodifiable(_courses);
  }

  @override
  void enrollUser({required String courseId, required String userId}) {
    // Si aún no existe el courseId en el mapa, lo crea con un set vacío
    final set = _enrollments.putIfAbsent(courseId, () => <String>{});
    set.add(userId); // Set evita duplicados automáticamente
  }

  @override
  List<String> listEnrolledUserIds(String courseId) {
    // Devuelve lista inmodificable (o lista vacía si no hay inscripciones)
    return List.unmodifiable(_enrollments[courseId] ?? <String>{});
  }
}
