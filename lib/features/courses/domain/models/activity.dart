class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String courseId;
  final String categoryId;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.courseId,
    required this.categoryId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      courseId: json['courseId'],
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'courseId': courseId,
      'categoryId': categoryId,
    };
  }

  Map<String, dynamic> toJsonNoId() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'courseId': courseId,
      'categoryId': categoryId,
    };
  }

  @override
  String toString() {
    return 'Activity{id: $id, title: $title, description: $description, date: $date, courseId: $courseId, categoryId: $categoryId}';
  }
}
