import '../../domain/models/assessment.dart';
import '../../domain/models/assessment_response.dart';

abstract class IAssessmentSource {
  // Assessment CRUD
  Future<List<Assessment>> getAssessmentsByCourseId(String courseId);
  Future<List<Assessment>> getAssessmentsByActivityId(String activityId);
  Future<Assessment?> getAssessmentById(String assessmentId);
  Future<bool> addAssessment(Assessment assessment);
  Future<bool> updateAssessment(Assessment assessment);
  Future<bool> deleteAssessment(String assessmentId);
  Future<bool> activateAssessment(String assessmentId);
  Future<bool> deactivateAssessment(String assessmentId);

  // Assessment Responses CRUD
  Future<List<AssessmentResponse>> getResponsesByAssessmentId(String assessmentId);
  Future<List<AssessmentResponse>> getResponsesByEvaluatorId(String evaluatorId, String assessmentId);
  Future<List<AssessmentResponse>> getResponsesByGroupId(String groupId, String assessmentId);
  Future<AssessmentResponse?> getResponseById(String responseId);
  Future<bool> addResponse(AssessmentResponse response);
  Future<bool> updateResponse(AssessmentResponse response);
  Future<bool> deleteResponse(String responseId);

  // Verificaciones
  Future<bool> hasStudentEvaluated(String evaluatorId, String evaluatedId, String assessmentId);
  Future<List<String>> getStudentsToEvaluate(String evaluatorId, String groupId, String assessmentId);
  Future<bool> isAssessmentActive(String assessmentId);
  Future<bool> canStudentSubmitResponse(String studentId, String assessmentId);
}
