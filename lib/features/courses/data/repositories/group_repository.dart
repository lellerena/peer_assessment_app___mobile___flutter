import 'package:loggy/loggy.dart';
import '../../domain/models/index.dart';
import '../../domain/repositories/i_group_repository.dart';
import '../datasources/i_group_source.dart';

class GroupRepository implements IGroupRepository {
  final IGroupSource localDataSource;
  final IGroupSource remoteDataSource;

  GroupRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Group>> getGroups() async {
    logInfo("Getting groups from repository");
    try {
      // Intentar obtener desde fuente remota primero
      final groups = await remoteDataSource.getGroups();
      // Guardar en local para caché
      for (final group in groups) {
        try {
          await localDataSource.addGroup(group);
        } catch (e) {
          // Si ya existe, actualizar
          await localDataSource.updateGroup(group);
        }
      }
      return groups;
    } catch (e) {
      logError("Error getting groups from remote, trying local: $e");
      // Si falla remoto, usar local
      return await localDataSource.getGroups();
    }
  }

  @override
  Future<Group> getGroupById(String id) async {
    logInfo("Getting group by id from repository: $id");
    try {
      // Intentar obtener desde fuente remota primero
      final group = await remoteDataSource.getGroupById(id);
      // Guardar en local para caché
      try {
        await localDataSource.addGroup(group);
      } catch (e) {
        // Si ya existe, actualizar
        await localDataSource.updateGroup(group);
      }
      return group;
    } catch (e) {
      logError("Error getting group from remote, trying local: $e");
      // Si falla remoto, usar local
      return await localDataSource.getGroupById(id);
    }
  }

  @override
  Future<List<Group>> getGroupsByCategoryId(String categoryId) async {
    logInfo("Getting groups by categoryId from repository: $categoryId");
    try {
      // Intentar obtener desde fuente remota primero
      final groups = await remoteDataSource.getGroupsByCategoryId(categoryId);
      // Guardar en local para caché
      for (final group in groups) {
        try {
          await localDataSource.addGroup(group);
        } catch (e) {
          // Si ya existe, actualizar
          await localDataSource.updateGroup(group);
        }
      }
      return groups;
    } catch (e) {
      logError("Error getting groups by categoryId from remote, trying local: $e");
      // Si falla remoto, usar local
      return await localDataSource.getGroupsByCategoryId(categoryId);
    }
  }

  @override
  Future<List<Group>> getGroupsByCourseId(String courseId) async {
    logInfo("Getting groups by courseId from repository: $courseId");
    try {
      // Intentar obtener desde fuente remota primero
      final groups = await remoteDataSource.getGroupsByCourseId(courseId);
      // Guardar en local para caché
      for (final group in groups) {
        try {
          await localDataSource.addGroup(group);
        } catch (e) {
          // Si ya existe, actualizar
          await localDataSource.updateGroup(group);
        }
      }
      return groups;
    } catch (e) {
      logError("Error getting groups by courseId from remote, trying local: $e");
      // Si falla remoto, usar local
      return await localDataSource.getGroupsByCourseId(courseId);
    }
  }

  @override
  Future<void> addGroup(Group group) async {
    logInfo("Adding group to repository: ${group.name}");
    try {
      // Agregar a fuente remota primero
      await remoteDataSource.addGroup(group);
      // Luego agregar a local para caché
      await localDataSource.addGroup(group);
    } catch (e) {
      logError("Error adding group to remote: $e");
      // Si falla remoto, solo agregar local
      await localDataSource.addGroup(group);
      rethrow;
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    logInfo("Updating group in repository: ${group.name}");
    try {
      // Actualizar en fuente remota primero
      await remoteDataSource.updateGroup(group);
      // Luego actualizar en local
      await localDataSource.updateGroup(group);
    } catch (e) {
      logError("Error updating group in remote: $e");
      // Si falla remoto, solo actualizar local
      await localDataSource.updateGroup(group);
      rethrow;
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    logInfo("Deleting group from repository: $id");
    try {
      // Eliminar de fuente remota primero
      await remoteDataSource.deleteGroup(id);
      // Luego eliminar de local
      await localDataSource.deleteGroup(id);
    } catch (e) {
      logError("Error deleting group from remote: $e");
      // Si falla remoto, solo eliminar local
      await localDataSource.deleteGroup(id);
      rethrow;
    }
  }
}
