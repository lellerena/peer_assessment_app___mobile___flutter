import 'package:loggy/loggy.dart';
import '../../../domain/models/group.dart';
import '../i_group_source.dart';

class LocalGroupSource implements IGroupSource {
  static final List<Group> _groups = [];

  @override
  Future<List<Group>> getGroups() async {
    logInfo("Getting groups from local source");
    return Future.value(List<Group>.from(_groups));
  }

  @override
  Future<Group> getGroupById(String id) async {
    logInfo("Getting group by id from local source: $id");
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (e) {
      logError("Group with id $id not found");
      return Future.error('Group with id $id not found');
    }
  }

  @override
  Future<List<Group>> getGroupsByCategoryId(String categoryId) async {
    logInfo("Getting groups by categoryId from local source: $categoryId");
    return _groups.where((group) => group.categoryId == categoryId).toList();
  }

  @override
  Future<List<Group>> getGroupsByCourseId(String courseId) async {
    logInfo("Getting groups by courseId from local source: $courseId");
    return _groups.where((group) => group.courseId == courseId).toList();
  }

  @override
  Future<void> addGroup(Group group) async {
    logInfo("Adding group to local source: ${group.name}");
    _groups.add(group);
  }

  @override
  Future<void> updateGroup(Group group) async {
    logInfo("Updating group in local source: ${group.name}");
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
    } else {
      logError("Group with id ${group.id} not found for update");
      return Future.error('Group with id ${group.id} not found');
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    logInfo("Deleting group from local source: $id");
    _groups.removeWhere((group) => group.id == id);
  }
}
