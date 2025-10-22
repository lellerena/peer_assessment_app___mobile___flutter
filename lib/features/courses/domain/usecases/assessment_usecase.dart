import '../models/assessment.dart';
import '../models/assessment_response.dart';
import '../repositories/i_assessment_repository.dart';

class AssessmentUseCase {
  final IAssessmentRepository _repository;

  AssessmentUseCase(this._repository);

  // Assessment CRUD
  Future<List<Assessment>> getAssessmentsByCourseId(String courseId) async {
    return await _repository.getAssessmentsByCourseId(courseId);
  }

  Future<List<Assessment>> getAssessmentsByActivityId(String activityId) async {
    return await _repository.getAssessmentsByActivityId(activityId);
  }

  Future<Assessment?> getAssessmentById(String assessmentId) async {
    return await _repository.getAssessmentById(assessmentId);
  }

  Future<bool> addAssessment(Assessment assessment) async {
    return await _repository.addAssessment(assessment);
  }

  Future<bool> updateAssessment(Assessment assessment) async {
    return await _repository.updateAssessment(assessment);
  }

  Future<bool> deleteAssessment(String assessmentId) async {
    return await _repository.deleteAssessment(assessmentId);
  }

  Future<bool> activateAssessment(String assessmentId) async {
    return await _repository.activateAssessment(assessmentId);
  }

  Future<bool> deactivateAssessment(String assessmentId) async {
    return await _repository.deactivateAssessment(assessmentId);
  }

  // Assessment Responses CRUD
  Future<List<AssessmentResponse>> getResponsesByAssessmentId(String assessmentId) async {
    return await _repository.getResponsesByAssessmentId(assessmentId);
  }

  Future<List<AssessmentResponse>> getResponsesByEvaluatorId(String evaluatorId, String assessmentId) async {
    return await _repository.getResponsesByEvaluatorId(evaluatorId, assessmentId);
  }

  Future<List<AssessmentResponse>> getResponsesByGroupId(String groupId, String assessmentId) async {
    return await _repository.getResponsesByGroupId(groupId, assessmentId);
  }

  Future<AssessmentResponse?> getResponseById(String responseId) async {
    return await _repository.getResponseById(responseId);
  }

  Future<bool> addResponse(AssessmentResponse response) async {
    return await _repository.addResponse(response);
  }

  Future<bool> updateResponse(AssessmentResponse response) async {
    return await _repository.updateResponse(response);
  }

  Future<bool> deleteResponse(String responseId) async {
    return await _repository.deleteResponse(responseId);
  }

  // Verificaciones
  Future<bool> hasStudentEvaluated(String evaluatorId, String evaluatedId, String assessmentId) async {
    return await _repository.hasStudentEvaluated(evaluatorId, evaluatedId, assessmentId);
  }

  Future<List<String>> getStudentsToEvaluate(String evaluatorId, String groupId, String assessmentId) async {
    return await _repository.getStudentsToEvaluate(evaluatorId, groupId, assessmentId);
  }

  Future<bool> isAssessmentActive(String assessmentId) async {
    return await _repository.isAssessmentActive(assessmentId);
  }

  Future<bool> canStudentSubmitResponse(String studentId, String assessmentId) async {
    return await _repository.canStudentSubmitResponse(studentId, assessmentId);
  }

  // Métodos de negocio específicos
  Future<bool> submitAssessmentResponse({
    required String assessmentId,
    required String evaluatorId,
    required String evaluatedId,
    required String courseId,
    required String groupId,
    required String activityId,
    required List<CriteriaResponse> criteriaResponses,
    String? comment,
  }) async {
    // Verificar que el estudiante puede enviar la respuesta
    final canSubmit = await canStudentSubmitResponse(evaluatorId, assessmentId);
    if (!canSubmit) {
      throw Exception('No se puede enviar la evaluación en este momento');
    }

    // Verificar que no se esté evaluando a sí mismo
    if (evaluatorId == evaluatedId) {
      throw Exception('No puedes evaluarte a ti mismo');
    }

    // Verificar que no haya evaluado ya a esta persona
    final hasEvaluated = await hasStudentEvaluated(evaluatorId, evaluatedId, assessmentId);
    if (hasEvaluated) {
      throw Exception('Ya has evaluado a este estudiante');
    }

    final response = AssessmentResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      assessmentId: assessmentId,
      evaluatorId: evaluatorId,
      evaluatedId: evaluatedId,
      courseId: courseId,
      groupId: groupId,
      categoryId: activityId,
      criteriaResponses: criteriaResponses,
      comment: comment,
      submittedAt: DateTime.now(),
    );

    return await addResponse(response);
  }

  Future<Map<String, dynamic>> getAssessmentResults(String assessmentId) async {
    final responses = await getResponsesByAssessmentId(assessmentId);
    
    // Agrupar por estudiante evaluado
    final Map<String, List<AssessmentResponse>> groupedByEvaluated = {};
    for (final response in responses) {
      if (!groupedByEvaluated.containsKey(response.evaluatedId)) {
        groupedByEvaluated[response.evaluatedId] = [];
      }
      groupedByEvaluated[response.evaluatedId]!.add(response);
    }

    // Calcular promedios para cada estudiante
    final Map<String, Map<String, dynamic>> results = {};
    for (final entry in groupedByEvaluated.entries) {
      final studentId = entry.key;
      final studentResponses = entry.value;
      
      // Calcular promedio por criterio
      final Map<String, List<double>> criteriaScores = {};
      for (final response in studentResponses) {
        for (final criteriaResponse in response.criteriaResponses) {
          if (!criteriaScores.containsKey(criteriaResponse.criteriaId)) {
            criteriaScores[criteriaResponse.criteriaId] = [];
          }
          
          // Convertir el valor a double según el tipo
          double score = 0.0;
          if (criteriaResponse.value is num) {
            score = (criteriaResponse.value as num).toDouble();
          } else if (criteriaResponse.value is bool) {
            score = (criteriaResponse.value as bool) ? 1.0 : 0.0;
          }
          
          criteriaScores[criteriaResponse.criteriaId]!.add(score);
        }
      }

      // Calcular promedios
      final Map<String, double> averages = {};
      for (final criteriaEntry in criteriaScores.entries) {
        final scores = criteriaEntry.value;
        final average = scores.isNotEmpty 
            ? scores.reduce((a, b) => a + b) / scores.length 
            : 0.0;
        averages[criteriaEntry.key] = average;
      }

      results[studentId] = {
        'totalEvaluations': studentResponses.length,
        'criteriaAverages': averages,
        'responses': studentResponses.map((r) => r.toJson()).toList(),
      };
    }

    return results;
  }
}
