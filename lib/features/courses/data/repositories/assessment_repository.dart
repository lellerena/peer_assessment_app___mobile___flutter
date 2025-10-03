import '../../domain/models/assessment.dart';
import '../../domain/models/assessment_response.dart';
import '../../domain/repositories/i_assessment_repository.dart';
import '../datasources/i_assessment_source.dart';

class AssessmentRepository implements IAssessmentRepository {
  final IAssessmentSource _source;

  AssessmentRepository(this._source);

  @override
  Future<List<Assessment>> getAssessmentsByCourseId(String courseId) async {
    return await _source.getAssessmentsByCourseId(courseId);
  }

  @override
  Future<List<Assessment>> getAssessmentsByCategoryId(String categoryId) async {
    return await _source.getAssessmentsByCategoryId(categoryId);
  }

  @override
  Future<Assessment?> getAssessmentById(String assessmentId) async {
    return await _source.getAssessmentById(assessmentId);
  }

  @override
  Future<bool> addAssessment(Assessment assessment) async {
    return await _source.addAssessment(assessment);
  }

  @override
  Future<bool> updateAssessment(Assessment assessment) async {
    return await _source.updateAssessment(assessment);
  }

  @override
  Future<bool> deleteAssessment(String assessmentId) async {
    return await _source.deleteAssessment(assessmentId);
  }

  @override
  Future<bool> activateAssessment(String assessmentId) async {
    return await _source.activateAssessment(assessmentId);
  }

  @override
  Future<bool> deactivateAssessment(String assessmentId) async {
    return await _source.deactivateAssessment(assessmentId);
  }

  @override
  Future<List<AssessmentResponse>> getResponsesByAssessmentId(String assessmentId) async {
    return await _source.getResponsesByAssessmentId(assessmentId);
  }

  @override
  Future<List<AssessmentResponse>> getResponsesByEvaluatorId(String evaluatorId, String assessmentId) async {
    return await _source.getResponsesByEvaluatorId(evaluatorId, assessmentId);
  }

  @override
  Future<List<AssessmentResponse>> getResponsesByGroupId(String groupId, String assessmentId) async {
    return await _source.getResponsesByGroupId(groupId, assessmentId);
  }

  @override
  Future<AssessmentResponse?> getResponseById(String responseId) async {
    return await _source.getResponseById(responseId);
  }

  @override
  Future<bool> addResponse(AssessmentResponse response) async {
    return await _source.addResponse(response);
  }

  @override
  Future<bool> updateResponse(AssessmentResponse response) async {
    return await _source.updateResponse(response);
  }

  @override
  Future<bool> deleteResponse(String responseId) async {
    return await _source.deleteResponse(responseId);
  }

  @override
  Future<bool> hasStudentEvaluated(String evaluatorId, String evaluatedId, String assessmentId) async {
    return await _source.hasStudentEvaluated(evaluatorId, evaluatedId, assessmentId);
  }

  @override
  Future<List<String>> getStudentsToEvaluate(String evaluatorId, String groupId, String assessmentId) async {
    return await _source.getStudentsToEvaluate(evaluatorId, groupId, assessmentId);
  }

  @override
  Future<bool> isAssessmentActive(String assessmentId) async {
    return await _source.isAssessmentActive(assessmentId);
  }

  @override
  Future<bool> canStudentSubmitResponse(String studentId, String assessmentId) async {
    return await _source.canStudentSubmitResponse(studentId, assessmentId);
  }
}
