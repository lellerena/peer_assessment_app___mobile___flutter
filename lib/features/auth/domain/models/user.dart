class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? password;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.student,
      ),
      password: json['password'],
    );
  }
}

// role
enum UserRole { teacher, student }
