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
    id: json["_id"],
    name: json["name"] ?? "---",
    groupingMethod: GroupingMethod.values.firstWhere(
      (e) => e.toString() == 'GroupingMethod.${json["groupingMethod"]}',
      orElse: () => GroupingMethod.random,
    ),
    groupSize: json["groupSize"] ?? 0,
    courseId: json["courseId"] ?? "---",
    groups: json["groups"] != null && json["groups"].containsKey("data")
        ? List<Group>.from(
            (json["groups"]["data"] as List).map((g) => Group.fromJson(g)),
          )
        : [],
  );

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
}
