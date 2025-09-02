class Course {
  final String id;             // Identificador único (lo generará el repositorio)
  final String name;           // Nombre del curso (p.ej. "Flutter Básico")
  final String? description;    // Descripción corta
  final String? createdByUserId; // ID del usuario que lo creó
  final List<String>? enrolledUserIds;

  Course({
    required this.id,
    required this.name,
    this.description,
    this.createdByUserId, 
    this.enrolledUserIds
  });
}
