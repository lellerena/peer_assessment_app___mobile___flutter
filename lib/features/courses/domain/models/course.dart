class Course {
  final String id;
  final String name;
  final String? description;
  final List<String> categoryIds;
  final String teacherId;
  final List<String> studentIds;

  Course({
    required this.id,
    required this.name,
    this.description,
    this.categoryIds = const [],
    required this.teacherId,
    this.studentIds = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryIds: List<String>.from(json['categoryIds'] ?? []),
      teacherId: json['teacherId'],
      studentIds: List<String>.from(json['studentIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryIds': categoryIds,
      'teacherId': teacherId,
      'studentIds': studentIds,
    };
  }

  Map<String, dynamic> toJsonNoId() {
    return {
      'name': name,
      'description': description,
      'categoryIds': categoryIds,
      'teacherId': teacherId,
      'studentIds': studentIds,
    };
  }
}
