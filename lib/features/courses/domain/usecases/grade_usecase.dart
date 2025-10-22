import '../../domain/models/grade.dart';
import '../../domain/repositories/i_grade_repository.dart';

class GradeUsecase {
  final IGradeRepository _repository;

  GradeUsecase(this._repository);

  Future<List<Grade>> getGradesByActivityId(String activityId) async {
    return await _repository.getGradesByActivityId(activityId);
  }

  Future<List<Grade>> getGradesByStudentId(String studentId) async {
    return await _repository.getGradesByStudentId(studentId);
  }

  Future<Grade?> getGradeById(String id) async {
    return await _repository.getGradeById(id);
  }

  Future<Grade> createGrade({
    required String assessmentId,
    required String activityId,
    required String courseId,
    required String groupId,
    required String studentId,
    required Map<String, dynamic> criterias,
    required String gradedBy,
    String? feedback,
  }) async {
    // Calcular la calificación final como promedio de los criterios
    final double finalGrade = _calculateFinalGrade(criterias);

    final grade = Grade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      assessmentId: assessmentId,
      activityId: activityId,
      courseId: courseId,
      groupId: groupId,
      studentId: studentId,
      criterias: criterias,
      finalGrade: finalGrade,
      feedback: feedback,
      gradedBy: gradedBy,
      gradedAt: DateTime.now(),
    );

    return await _repository.createGrade(grade);
  }

  Future<Grade> updateGrade(Grade grade) async {
    return await _repository.updateGrade(grade);
  }

  Future<bool> deleteGrade(String id) async {
    return await _repository.deleteGrade(id);
  }

  double _calculateFinalGrade(Map<String, dynamic> criterias) {
    if (criterias.isEmpty) return 0.0;
    
    double sum = 0.0;
    int count = 0;
    
    criterias.forEach((key, value) {
      if (value is num) {
        sum += value.toDouble();
        count++;
      }
    });
    
    return count > 0 ? sum / count : 0.0;
  }
}
