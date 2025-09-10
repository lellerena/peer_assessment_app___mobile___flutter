enum GroupingMethod { random, selfAssigned, manual }

class Category {
  Category({
    required this.id,
    required this.name,
    required this.groupingMethod,
    required this.groupSize,
    required this.courseId,
  });

  final String id;
  final String name;
  final GroupingMethod groupingMethod;
  final int groupSize;
  final String courseId;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["_id"],
    name: json["name"] ?? "---",
    groupingMethod: GroupingMethod.values.firstWhere(
      (e) => e.toString() == 'GroupingMethod.${json["groupingMethod"]}',
      orElse: () => GroupingMethod.random,
    ),
    groupSize: json["groupSize"] ?? 0,
    courseId: json["courseId"] ?? "---",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "groupingMethod": groupingMethod.name,
    "groupSize": groupSize,
    "courseId": courseId,
  };

  Map<String, dynamic> toJsonNoId() => {
    "name": name,
    "groupingMethod": groupingMethod.name,
    "groupSize": groupSize,
    "courseId": courseId,
  };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, groupingMethod: $groupingMethod, groupSize: $groupSize, courseId: $courseId}';
  }
}
