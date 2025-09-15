import 'user_role.dart';
import 'user.dart';

class UserPublic {
  String? id;
  final String name;
  final String email;
  final UserRole role;

  UserPublic({
    this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserPublic.fromJson(Map<String, dynamic> json) {
    return UserPublic(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.student,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
    };
  }

  // Conversión a User (requiere password)
  User toUser(String password) {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      password: password,
    );
  }
}
