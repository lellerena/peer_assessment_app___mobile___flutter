import '../../domain/models/index.dart';

abstract class IGroupSource {
  Future<List<Group>> getGroups();
  Future<Group> getGroupById(String id);
  Future<List<Group>> getGroupsByCategoryId(String categoryId);
  Future<List<Group>> getGroupsByCourseId(String courseId);
  Future<void> addGroup(Group group);
  Future<void> updateGroup(Group group);
  Future<void> deleteGroup(String id);
}
