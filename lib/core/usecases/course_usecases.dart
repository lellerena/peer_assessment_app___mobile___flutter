import '../contracts/course_repository.dart';
import '../entities/course.dart';
import '../contracts/auth_repository.dart';
import '../entities/user.dart';

/// Crear curso (el repo genera el id)
class CreateCourse {
  final CourseRepository repo;
  CreateCourse(this.repo);

  Course call({
    required String name,
    required String description,
    required String createdByUserId,
  }) {
    return repo.createCourse(
      name: name,
      description: description,
      createdByUserId: createdByUserId,
    );
  }
}

/// Listar todos los cursos
class ListCourses {
  final CourseRepository repo;
  ListCourses(this.repo);

  List<Course> call() => repo.listCourses();
}

/// Inscribir un usuario (por userId) en un curso (por courseId)
class EnrollUserInCourse {
  final CourseRepository repo;
  EnrollUserInCourse(this.repo);

  void call({
    required String courseId,
    required String userId,
  }) {
    repo.enrollUser(courseId: courseId, userId: userId);
  }
}

/// Obtener SOLO los IDs de usuarios inscritos en un curso
class ListEnrolledUserIds {
  final CourseRepository repo;
  ListEnrolledUserIds(this.repo);

  List<String> call(String courseId) => repo.listEnrolledUserIds(courseId);
  
}


class GetEnrolledUsers {
  final CourseRepository courses;
  final AuthRepository auth;
  GetEnrolledUsers(this.courses, this.auth);

  List<User> call(String courseId) {
    final ids = courses.listEnrolledUserIds(courseId);
    final users = <User>[];
    for (final id in ids) {
      final u = auth.findById(id);
      if (u != null) users.add(u);
    }
    return users;
  }
}
