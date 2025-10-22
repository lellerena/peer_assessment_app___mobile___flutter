import '../models/index.dart';
import '../repositories/i_group_repository.dart';

class GetGroups {
  final IGroupRepository repository;

  GetGroups(this.repository);

  Future<List<Group>> call() async {
    return await repository.getGroups();
  }
}

class GetGroupById {
  final IGroupRepository repository;

  GetGroupById(this.repository);

  Future<Group> call(String id) async {
    return await repository.getGroupById(id);
  }
}

class GetGroupsByCategoryId {
  final IGroupRepository repository;

  GetGroupsByCategoryId(this.repository);

  Future<List<Group>> call(String categoryId) async {
    return await repository.getGroupsByCategoryId(categoryId);
  }
}

class GetGroupsByCourseId {
  final IGroupRepository repository;

  GetGroupsByCourseId(this.repository);

  Future<List<Group>> call(String courseId) async {
    return await repository.getGroupsByCourseId(courseId);
  }
}

class AddGroup {
  final IGroupRepository repository;

  AddGroup(this.repository);

  Future<void> call(Group group) async {
    return await repository.addGroup(group);
  }
}

class UpdateGroup {
  final IGroupRepository repository;

  UpdateGroup(this.repository);

  Future<void> call(Group group) async {
    return await repository.updateGroup(group);
  }
}

class DeleteGroup {
  final IGroupRepository repository;

  DeleteGroup(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteGroup(id);
  }
}
