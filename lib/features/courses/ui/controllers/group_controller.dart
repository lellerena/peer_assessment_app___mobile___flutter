import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/index.dart';
import '../../domain/usecases/group_usecases.dart';

class GroupController extends GetxController with UiLoggy {
  final GetGroups getGroups;
  final GetGroupById getGroupByIdUseCase;
  final GetGroupsByCategoryId getGroupsByCategoryId;
  final GetGroupsByCourseId getGroupsByCourseId;
  final AddGroup addGroup;
  final UpdateGroup updateGroup;
  final DeleteGroup deleteGroup;

  GroupController({
    required this.getGroups,
    required this.getGroupByIdUseCase,
    required this.getGroupsByCategoryId,
    required this.getGroupsByCourseId,
    required this.addGroup,
    required this.updateGroup,
    required this.deleteGroup,
  });

  final RxList<Group> groups = <Group>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo("Loading groups...");
      
      final groupsList = await getGroups();
      groups.assignAll(groupsList);
      
      logInfo("Loaded ${groups.length} groups");
    } catch (e) {
      logError("Error loading groups: $e");
      errorMessage.value = 'Error al cargar grupos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupsByCategoryId(String categoryId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo("Loading groups by categoryId: $categoryId");
      
      final groupsList = await getGroupsByCategoryId(categoryId);
      groups.assignAll(groupsList);
      
      logInfo("Loaded ${groups.length} groups for category $categoryId");
    } catch (e) {
      logError("Error loading groups by categoryId: $e");
      errorMessage.value = 'Error al cargar grupos por categoría: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupsByCourseId(String courseId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo("Loading groups by courseId: $courseId");
      
      final groupsList = await getGroupsByCourseId(courseId);
      groups.assignAll(groupsList);
      
      logInfo("Loaded ${groups.length} groups for course $courseId");
    } catch (e) {
      logError("Error loading groups by courseId: $e");
      errorMessage.value = 'Error al cargar grupos por curso: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Group?> getGroupById(String id) async {
    try {
      logInfo("Getting group by id: $id");
      return await getGroupByIdUseCase(id);
    } catch (e) {
      logError("Error getting group by id: $e");
      errorMessage.value = 'Error al obtener grupo: $e';
      return null;
    }
  }

  Future<bool> createGroup(Group group) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo("Creating group: ${group.name}");
      
      await addGroup(group);
      await loadGroups(); // Recargar la lista
      
      logInfo("Group created successfully");
      return true;
    } catch (e) {
      logError("Error creating group: $e");
      errorMessage.value = 'Error al crear grupo: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> editGroup(Group group) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo("Updating group: ${group.name}");
      
      await updateGroup(group);
      await loadGroups(); // Recargar la lista
      
      logInfo("Group updated successfully");
      return true;
    } catch (e) {
      logError("Error updating group: $e");
      errorMessage.value = 'Error al actualizar grupo: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> removeGroup(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      logInfo("Deleting group: $id");
      
      await deleteGroup(id);
      groups.removeWhere((group) => group.id == id);
      
      logInfo("Group deleted successfully");
      return true;
    } catch (e) {
      logError("Error deleting group: $e");
      errorMessage.value = 'Error al eliminar grupo: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  List<Group> getGroupsByCategory(String categoryId) {
    return groups.where((group) => group.categoryId == categoryId).toList();
  }

  List<Group> getGroupsByCourse(String courseId) {
    return groups.where((group) => group.courseId == courseId).toList();
  }

  Group? findGroupById(String id) {
    try {
      return groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }
}
