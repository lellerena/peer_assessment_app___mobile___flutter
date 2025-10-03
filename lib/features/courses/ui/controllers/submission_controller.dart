import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../domain/models/submission.dart';
import '../../domain/usecases/submission_usecase.dart';

class SubmissionController extends GetxController with UiLoggy {
  final SubmissionUseCase _submissionUseCase;

  RxBool isLoading = false.obs;
  RxList<Submission> submissions = <Submission>[].obs;
  Rx<Submission?> selectedSubmission = Rx<Submission?>(null);

  SubmissionController(this._submissionUseCase);

  Future<void> getSubmissionsByActivityId(String activityId) async {
    isLoading.value = true;
    try {
      final result = await _submissionUseCase.getSubmissionsByActivityId(
        activityId,
      );
      submissions.assignAll(result);
      loggy.info(
        'Loaded ${submissions.length} submissions for activity $activityId',
      );
    } catch (e) {
      loggy.error('Error loading submissions: $e');
      Get.snackbar('Error', 'No se pudieron cargar las entregas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSubmissionsByStudentId(String studentId) async {
    isLoading.value = true;
    try {
      final result = await _submissionUseCase.getSubmissionsByStudentId(
        studentId,
      );
      submissions.assignAll(result);
      loggy.info(
        'Loaded ${submissions.length} submissions for student $studentId',
      );
    } catch (e) {
      loggy.error('Error loading submissions: $e');
      Get.snackbar('Error', 'No se pudieron cargar las entregas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSubmissionsByGroupId(String groupId) async {
    isLoading.value = true;
    try {
      final result = await _submissionUseCase.getSubmissionsByGroupId(groupId);
      submissions.assignAll(result);
      loggy.info('Loaded ${submissions.length} submissions for group $groupId');
    } catch (e) {
      loggy.error('Error loading submissions: $e');
      Get.snackbar('Error', 'No se pudieron cargar las entregas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSubmissionsByCourseId(String courseId) async {
    isLoading.value = true;
    try {
      final result = await _submissionUseCase.getSubmissionsByCourseId(
        courseId,
      );
      submissions.assignAll(result);
      loggy.info(
        'Loaded ${submissions.length} submissions for course $courseId',
      );
    } catch (e) {
      loggy.error('Error loading submissions: $e');
      Get.snackbar('Error', 'No se pudieron cargar las entregas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addSubmission(Submission submission) async {
    isLoading.value = true;
    try {
      // Validamos que estamos usando un objeto válido sin un ID real (la API lo generará)
      if (submission.id.isNotEmpty &&
          submission.id != '0' &&
          submission.id != '-1') {
        loggy.warning(
          'Attempt to add submission with existing ID: ${submission.id}',
        );
      }

      final result = await _submissionUseCase.addSubmission(submission);
      if (result) {
        Get.snackbar('Éxito', 'Entrega enviada correctamente');
        // Refresh the list if we're viewing this activity's submissions
        if (submissions.isNotEmpty &&
            submissions.first.activityId == submission.activityId) {
          getSubmissionsByActivityId(submission.activityId);
        } else {
          // Actualizar la lista de entregas para esta actividad
          await getSubmissionsByActivityId(submission.activityId);
        }
      }
      return result;
    } catch (e) {
      loggy.error('Error adding submission: $e');
      Get.snackbar('Error', 'No se pudo enviar la entrega: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateSubmission(Submission submission) async {
    isLoading.value = true;
    try {
      // Validamos que estamos usando un ID válido
      if (submission.id.isEmpty) {
        loggy.error('Attempted to update submission with empty ID');
        Get.snackbar('Error', 'No se puede actualizar una entrega sin ID');
        return false;
      }

      final result = await _submissionUseCase.updateSubmission(submission);
      if (result) {
        Get.snackbar('Éxito', 'Entrega actualizada correctamente');
        // Update the local list
        final index = submissions.indexWhere((s) => s.id == submission.id);
        if (index != -1) {
          submissions[index] = submission;
          submissions.refresh();
        } else {
          // Si no está en la lista local, refrescar desde el servidor
          await getSubmissionsByActivityId(submission.activityId);
        }
      }
      return result;
    } catch (e) {
      loggy.error('Error updating submission: $e');
      Get.snackbar('Error', 'No se pudo actualizar la entrega: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteSubmission(String submissionId) async {
    isLoading.value = true;
    try {
      final result = await _submissionUseCase.deleteSubmission(submissionId);
      if (result) {
        Get.snackbar('Éxito', 'Entrega eliminada correctamente');
        // Remove from the local list
        submissions.removeWhere((s) => s.id == submissionId);
      }
      return result;
    } catch (e) {
      loggy.error('Error deleting submission: $e');
      Get.snackbar('Error', 'No se pudo eliminar la entrega');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSubmissionById(String submissionId) async {
    isLoading.value = true;
    try {
      final result = await _submissionUseCase.getSubmissionById(submissionId);
      if (result != null) {
        selectedSubmission.value = result;
      }
    } catch (e) {
      loggy.error('Error getting submission: $e');
      Get.snackbar('Error', 'No se pudo obtener la entrega');
    } finally {
      isLoading.value = false;
    }
  }
}
