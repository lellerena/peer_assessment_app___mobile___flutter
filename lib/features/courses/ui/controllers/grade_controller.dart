import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/models/grade.dart';
import '../../domain/usecases/grade_usecase.dart';

class GradeController extends GetxController {
  final GradeUsecase _usecase;

  GradeController(this._usecase);

  final RxList<Grade> grades = <Grade>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getGradesByActivityId(String activityId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _usecase.getGradesByActivityId(activityId);
      grades.value = result;
      
      logInfo('Calificaciones cargadas: ${result.length}');
    } catch (e) {
      errorMessage.value = 'Error al cargar calificaciones: $e';
      logError('Error al cargar calificaciones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGradesByStudentId(String studentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _usecase.getGradesByStudentId(studentId);
      grades.value = result;
      
      logInfo('Calificaciones del estudiante cargadas: ${result.length}');
    } catch (e) {
      errorMessage.value = 'Error al cargar calificaciones del estudiante: $e';
      logError('Error al cargar calificaciones del estudiante: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGrade({
    required String assessmentId,
    required String activityId,
    required String courseId,
    required String groupId,
    required String studentId,
    required Map<String, dynamic> criterias,
    required String gradedBy,
    String? feedback,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final grade = await _usecase.createGrade(
        assessmentId: assessmentId,
        activityId: activityId,
        courseId: courseId,
        groupId: groupId,
        studentId: studentId,
        criterias: criterias,
        gradedBy: gradedBy,
        feedback: feedback,
      );
      
      grades.add(grade);
      logInfo('Calificación creada exitosamente: ${grade.id}');
      return true;
    } catch (e) {
      errorMessage.value = 'Error al crear calificación: $e';
      logError('Error al crear calificación: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateGrade(Grade grade) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final updatedGrade = await _usecase.updateGrade(grade);
      
      final index = grades.indexWhere((g) => g.id == grade.id);
      if (index != -1) {
        grades[index] = updatedGrade;
      }
      
      logInfo('Calificación actualizada exitosamente: ${grade.id}');
      return true;
    } catch (e) {
      errorMessage.value = 'Error al actualizar calificación: $e';
      logError('Error al actualizar calificación: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteGrade(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final success = await _usecase.deleteGrade(id);
      
      if (success) {
        grades.removeWhere((g) => g.id == id);
        logInfo('Calificación eliminada exitosamente: $id');
      }
      
      return success;
    } catch (e) {
      errorMessage.value = 'Error al eliminar calificación: $e';
      logError('Error al eliminar calificación: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}
