import '../models/grade.dart';

abstract class IGradeRepository {
  Future<List<Grade>> getGradesByActivityId(String activityId);
  Future<List<Grade>> getGradesByStudentId(String studentId);
  Future<Grade?> getGradeById(String id);
  Future<Grade> createGrade(Grade grade);
  Future<Grade> updateGrade(Grade grade);
  Future<bool> deleteGrade(String id);
}
