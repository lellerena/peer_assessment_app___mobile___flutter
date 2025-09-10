class User {
  final String id;
  final String name;
  final String email;
  final String? password; // opcional

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
  });
}

