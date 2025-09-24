class Group {
  final String id;
  final String name;
  final List<String> studentIds;
  final DateTime? createdAt;
  // Puedes agregar más campos útiles aquí

  Group({
    required this.id,
    required this.name,
    required this.studentIds,
    this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json["id"] ?? "",
    name: json["name"] ?? "Grupo",
    studentIds: List<String>.from(json["studentIds"] ?? []),
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "studentIds": studentIds,
    if (createdAt != null) "createdAt": createdAt!.toIso8601String(),
  };
}
