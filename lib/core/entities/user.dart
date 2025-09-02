class User {
  final String id;
  final String email;
  String name;
  // Nota: en memoria para demo; en prod usa hash/salts.
  final String password;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
  });
}

final u = User(
  id: 'u1',
  email: 'ana@example.com',
  name: 'Ana',
  password: '123456', // solo demo
);