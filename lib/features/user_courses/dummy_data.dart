import '../courses/domain/models/course.dart';
import '../../core/entities/user.dart';

final List<User> dummyUsers = [
  User(id: 'u1', name: 'Jhon', email: 'jhon@example.com', password: ''),
  User(id: 'u2', name: 'Ana',  email: 'ana@example.com',  password: ''),
];

final List<Course> dummyCourses = [
  Course(id: 'c1', name: 'Flutter Básico', description: 'Intro',   createdByUserId: 'admin', enrolledUserIds: ['u1']),
  Course(id: 'c2', name: 'Dart Avanzado',  description: 'Streams', createdByUserId: 'admin', enrolledUserIds: ['u2']),
];

