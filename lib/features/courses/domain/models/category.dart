import './group.dart';

enum GroupingMethod { random, selfAssigned, manual }

class Category {
  Category({
    required this.id,
    required this.name,
    required this.groupingMethod,
    required this.groupSize,
    required this.courseId,
    this.groups = const [],
  });

  final String id;
  final String name;
  final GroupingMethod groupingMethod;
  final int groupSize;
  final String courseId;
  final List<Group> groups;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"] ?? json["id"] ?? "",
    name: json["name"] ?? "---",
    groupingMethod: _parseGroupingMethod(json["groupingMethod"]),
    groupSize: json["groupSize"] ?? 0,
    courseId: json["courseId"] ?? "---",
    groups: _parseGroups(json["groups"]),
  );

  static GroupingMethod _parseGroupingMethod(dynamic value) {
    if (value == null) return GroupingMethod.random;
    if (value is String) {
      return GroupingMethod.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GroupingMethod.random,
      );
    }
    return GroupingMethod.random;
  }

  static List<Group> _parseGroups(dynamic groupsData) {
    if (groupsData == null) return [];
    
    // Si viene con estructura anidada {"data": [...]}
    if (groupsData is Map && groupsData.containsKey("data")) {
      final data = groupsData["data"];
      if (data is List) {
        return data.map((g) => Group.fromJson(g)).toList();
      }
    }
    
    // Si viene como lista directa
    if (groupsData is List) {
      return groupsData.map((g) => Group.fromJson(g)).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "groupingMethod": groupingMethod.name,
    "groupSize": groupSize,
    "courseId": courseId,
    "groups": groups.map((g) => g.toJson()).toList(),
  };

  Map<String, dynamic> toJsonNoId() => {
    "name": name,
    "groupingMethod": groupingMethod.name,
    "groupSize": groupSize,
    "courseId": courseId,
    "groups": groups.map((g) => g.toJson()).toList(),
  };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, groupingMethod: $groupingMethod, groupSize: $groupSize, courseId: $courseId, groups: $groups}';
  }

  // Método para parsear el método de agrupación de manera segura
  static GroupingMethod _parseGroupingMethod(dynamic value) {
    if (value == null) return GroupingMethod.random;
    if (value is String) {
      return GroupingMethod.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GroupingMethod.random,
      );
    }
    return GroupingMethod.random;
  }

  // Método para parsear grupos de manera segura
  static List<Group> _parseGroups(dynamic groupsData) {
    if (groupsData == null) return [];

    // Si es una lista directa
    if (groupsData is List) {
      return groupsData.map((g) => Group.fromJson(g)).toList();
    }
    
    // Si es un Map, verificar si tiene la clave "data"
    if (groupsData is Map<String, dynamic>) {
      if (groupsData.containsKey("data")) {
        final data = groupsData["data"];
        if (data is List) {
          return data.map((g) => Group.fromJson(g)).toList();
        }
      }
    }

    // Fallback para tipos inesperados
    return [];
  }
}
