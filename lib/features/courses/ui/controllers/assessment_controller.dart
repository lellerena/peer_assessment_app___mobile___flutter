import 'package:get/get.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/assessment_response.dart';
import '../../domain/models/category.dart';
import '../../domain/usecases/assessment_usecase.dart';
import '../../domain/usecases/category_usecase.dart';
import '../../domain/usecases/activity_usecase.dart';

class AssessmentController extends GetxController {
  final AssessmentUseCase assessmentUseCase;
  final CategoryUseCase categoryUseCase;
  final ActivityUseCase activityUseCase;
  final String courseId;

  final RxList<Assessment> _assessments = <Assessment>[].obs;
  final RxList<AssessmentResponse> _responses = <AssessmentResponse>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  AssessmentController(this.assessmentUseCase, this.categoryUseCase, this.activityUseCase, this.courseId);

  List<Assessment> get assessments => _assessments;
  List<AssessmentResponse> get responses => _responses;

  @override
  void onInit() {
    super.onInit();
    getAssessments();
  }

  @override
  void onClose() {
    super.onClose();
    _assessments.clear();
    _responses.clear();
    isLoading.value = false;
    errorMessage.value = '';
  }

  Future<void> getAssessments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _assessments.value = await assessmentUseCase.getAssessmentsByCourseId(courseId);
    } catch (e) {
      print("Error getting assessments: $e");
      errorMessage.value = "Error loading assessments: $e";
      _assessments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAssessment(Assessment assessment) async {
    try {
      isLoading.value = true;
      await assessmentUseCase.addAssessment(assessment);
      await getAssessments();
    } catch (e) {
      print("Error adding assessment: $e");
      errorMessage.value = "Error adding assessment: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAssessment(Assessment assessment) async {
    try {
      isLoading.value = true;
      await assessmentUseCase.updateAssessment(assessment);
      await getAssessments();
    } catch (e) {
      print("Error updating assessment: $e");
      errorMessage.value = "Error updating assessment: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAssessment(String assessmentId) async {
    try {
      isLoading.value = true;
      await assessmentUseCase.deleteAssessment(assessmentId);
      await getAssessments();
    } catch (e) {
      print("Error deleting assessment: $e");
      errorMessage.value = "Error deleting assessment: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activateAssessment(String assessmentId) async {
    try {
      isLoading.value = true;
      await assessmentUseCase.activateAssessment(assessmentId);
      await getAssessments();
    } catch (e) {
      print("Error activating assessment: $e");
      errorMessage.value = "Error activating assessment: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deactivateAssessment(String assessmentId) async {
    try {
      isLoading.value = true;
      await assessmentUseCase.deactivateAssessment(assessmentId);
      await getAssessments();
    } catch (e) {
      print("Error deactivating assessment: $e");
      errorMessage.value = "Error deactivating assessment: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getResponsesForAssessment(String assessmentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _responses.value = await assessmentUseCase.getResponsesByAssessmentId(assessmentId);
    } catch (e) {
      print("Error getting responses: $e");
      errorMessage.value = "Error loading responses: $e";
      _responses.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitAssessmentResponse({
    required String assessmentId,
    required String evaluatorId,
    required String evaluatedId,
    required String groupId,
    required String activityId,
    required List<CriteriaResponse> criteriaResponses,
    String? comment,
  }) async {
    try {
      isLoading.value = true;
      final result = await assessmentUseCase.submitAssessmentResponse(
        assessmentId: assessmentId,
        evaluatorId: evaluatorId,
        evaluatedId: evaluatedId,
        courseId: courseId,
        groupId: groupId,
        activityId: activityId,
        criteriaResponses: criteriaResponses,
        comment: comment,
      );
      
      if (result) {
        await getResponsesForAssessment(assessmentId);
      }
      
      return result;
    } catch (e) {
      print("Error submitting assessment response: $e");
      errorMessage.value = "Error submitting response: $e";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> getAssessmentResults(String assessmentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final results = await assessmentUseCase.getAssessmentResults(assessmentId);
      return results;
    } catch (e) {
      print("Error getting assessment results: $e");
      errorMessage.value = "Error loading results: $e";
      return {};
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> canStudentSubmitResponse(String studentId, String assessmentId) async {
    try {
      return await assessmentUseCase.canStudentSubmitResponse(studentId, assessmentId);
    } catch (e) {
      print("Error checking if student can submit: $e");
      return false;
    }
  }

  Future<bool> hasStudentEvaluated(String evaluatorId, String evaluatedId, String assessmentId) async {
    try {
      return await assessmentUseCase.hasStudentEvaluated(evaluatorId, evaluatedId, assessmentId);
    } catch (e) {
      print("Error checking if student has evaluated: $e");
      return false;
    }
  }

  Future<List<String>> getStudentsToEvaluate(String evaluatorId, String groupId, String assessmentId) async {
    try {
      return await assessmentUseCase.getStudentsToEvaluate(evaluatorId, groupId, assessmentId);
    } catch (e) {
      print("Error getting students to evaluate: $e");
      return [];
    }
  }

  // Método para obtener los grupos de una categoría específica
  Future<List<Category>> getCategoriesForCourse() async {
    try {
      return await categoryUseCase.getCategoriesByCourseId(courseId);
    } catch (e) {
      print("Error getting categories: $e");
      return [];
    }
  }

  // Método para obtener estudiantes de un grupo específico
  Future<List<String>> getStudentsInGroup(String categoryId, String groupId) async {
    try {
      final categories = await getCategoriesForCourse();
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );
      
      final group = category.groups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => throw Exception('Group not found'),
      );
      
      return group.studentIds;
    } catch (e) {
      print("Error getting students in group: $e");
      return [];
    }
  }
}
