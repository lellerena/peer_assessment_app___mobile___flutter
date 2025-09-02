class Course {
  final String id;
  final String name;
  final List<String> enrolledUserIds;

  Course({
    required this.id, 
    required this.name, 
    required this.enrolledUserIds
  });
}
