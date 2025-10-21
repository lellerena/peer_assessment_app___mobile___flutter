class Group {
  final String id;
  final String name;
  final String categoryId;
  final String courseId;
  final List<String> studentIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Group({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.courseId,
    required this.studentIds,
    this.createdAt,
    this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json["_id"] ?? json["id"] ?? "",
    name: json["name"] ?? "Grupo",
    categoryId: json["categoryIds"] ?? json["categoryId"] ?? "", // Leer categoryIds primero, luego categoryId como fallback
    courseId: json["courseId"] ?? "",
    studentIds: _parseStudentIds(json["studentIds"]), // Leer studentIds directamente
    createdAt: _parseDateTime(json["createdAt"]),
    updatedAt: _parseDateTime(json["updatedAt"]),
  );

  static List<String> _parseStudentIds(dynamic studentIdsData) {
    if (studentIdsData == null) return [];
    
    // Si viene con estructura anidada {"data": [...]}
    if (studentIdsData is Map && studentIdsData.containsKey("data")) {
      final data = studentIdsData["data"];
      if (data is List) {
        return List<String>.from(data);
      }
    }
    
    // Si viene como lista directa
    if (studentIdsData is List) {
      return List<String>.from(studentIdsData);
    }
    
    return [];
  }

  static DateTime? _parseDateTime(dynamic dateTimeData) {
    if (dateTimeData == null) return null;
    if (dateTimeData is String) {
      try {
        return DateTime.parse(dateTimeData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "categoryIds": categoryId, // Corregido: categoryIds en lugar de categoryId
    "courseId": courseId,
    "studentIds": studentIds, // Array directo para Roble
    if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
    if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
  };

  Map<String, dynamic> toJsonNoId() => {
    "name": name,
    "categoryIds": categoryId, // Corregido: categoryIds en lugar de categoryId
    "courseId": courseId,
    "studentIds": studentIds, // Array directo para Roble
    if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
    if (updatedAt != null) "updatedAt": updatedAt!.toIso8601String(),
  };

  Group copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? courseId,
    List<String>? studentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      courseId: courseId ?? this.courseId,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Group{id: $id, name: $name, categoryId: $categoryId, courseId: $courseId, studentIds: $studentIds, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group &&
        other.id == id &&
        other.name == name &&
        other.categoryId == categoryId &&
        other.courseId == courseId &&
        other.studentIds.toString() == studentIds.toString() &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        categoryId.hashCode ^
        courseId.hashCode ^
        studentIds.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
