class Course {
  final String id;
  final String name;
  final String? description;
  final String? createdByUserId;
  // 👇 HAZLO NO-NULLABLE y con default []
  final List<String> enrolledUserIds;

  const Course({
    required this.id,
    required this.name,
    this.description,
    this.createdByUserId,
    this.enrolledUserIds = const [],
  });
}
