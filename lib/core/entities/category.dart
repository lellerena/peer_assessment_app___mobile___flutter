enum GroupingMethod { random, selfAssigned, manual }

class Category {
  final String id;
  String name;
  GroupingMethod groupingMethod;
  int groupSize;

  Category({
    required this.id,
    required this.name,
    required this.groupingMethod,
    required this.groupSize,
  });
}
