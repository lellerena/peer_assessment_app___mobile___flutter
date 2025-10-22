import '../../domain/models/grade.dart';
import '../../domain/repositories/i_grade_repository.dart';
import '../datasources/i_grade_source.dart';

class GradeRepository implements IGradeRepository {
  final IGradeSource _source;

  GradeRepository(this._source);

  @override
  Future<List<Grade>> getGradesByActivityId(String activityId) async {
    final data = await _source.getGradesByActivityId(activityId);
    return data.map((json) => Grade.fromJson(json)).toList();
  }

  @override
  Future<List<Grade>> getGradesByStudentId(String studentId) async {
    final data = await _source.getGradesByStudentId(studentId);
    return data.map((json) => Grade.fromJson(json)).toList();
  }

  @override
  Future<Grade?> getGradeById(String id) async {
    final data = await _source.getGradeById(id);
    return data != null ? Grade.fromJson(data) : null;
  }

  @override
  Future<Grade> createGrade(Grade grade) async {
    final data = await _source.createGrade(grade.toJsonNoId());
    return Grade.fromJson(data);
  }

  @override
  Future<Grade> updateGrade(Grade grade) async {
    final data = await _source.updateGrade(grade.toJson());
    return Grade.fromJson(data);
  }

  @override
  Future<bool> deleteGrade(String id) async {
    return await _source.deleteGrade(id);
  }
}
