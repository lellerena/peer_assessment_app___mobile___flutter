abstract class IGradeSource {
  Future<List<Map<String, dynamic>>> getGradesByActivityId(String activityId);
  Future<List<Map<String, dynamic>>> getGradesByStudentId(String studentId);
  Future<Map<String, dynamic>?> getGradeById(String id);
  Future<Map<String, dynamic>> createGrade(Map<String, dynamic> grade);
  Future<Map<String, dynamic>> updateGrade(Map<String, dynamic> grade);
  Future<bool> deleteGrade(String id);
}
