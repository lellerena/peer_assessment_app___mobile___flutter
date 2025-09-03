import '../../core/entities/user.dart';
import '../../core/entities/course.dart';

final dummyUsers = [
  User(id: 'u1', name: 'Jhon', email: '', password: ''),
  User(id: 'u2', name: 'María', email: '', password: ''),
  User(id: 'u3', name: 'Pedro', email: '', password: ''),
];

final dummyCourses = [
  Course(id: 'c1', name: 'Programación Móvil', enrolledUserIds: ['u1', 'u2']),
  Course(id: 'c2', name: 'Bases de Datos', enrolledUserIds: ['u2']),
  Course(id: 'c3', name: 'Diseño de Software', enrolledUserIds: ['u1', 'u3']),
];
