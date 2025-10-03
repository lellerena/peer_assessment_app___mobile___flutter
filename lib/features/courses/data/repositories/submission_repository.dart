import '../datasources/i_submission_source.dart';

import '../../domain/models/submission.dart';
import '../../domain/repositories/i_submission_repository.dart';

class SubmissionRepository implements ISubmissionRepository {
  final ISubmissionDataSource _dataSource;

  SubmissionRepository(this._dataSource);

  @override
  Future<List<Submission>> getSubmissionsByActivityId(String activityId) async {
    return await _dataSource.getSubmissionsByActivityId(activityId);
  }

  @override
  Future<List<Submission>> getSubmissionsByStudentId(String studentId) async {
    return await _dataSource.getSubmissionsByStudentId(studentId);
  }

  @override
  Future<List<Submission>> getSubmissionsByGroupId(String groupId) async {
    return await _dataSource.getSubmissionsByGroupId(groupId);
  }

  @override
  Future<List<Submission>> getSubmissionsByCourseId(String courseId) async {
    return await _dataSource.getSubmissionsByCourseId(courseId);
  }

  @override
  Future<bool> addSubmission(Submission submission) async {
    return await _dataSource.addSubmission(submission);
  }

  @override
  Future<bool> updateSubmission(Submission submission) async {
    return await _dataSource.updateSubmission(submission);
  }

  @override
  Future<bool> deleteSubmission(String submissionId) async {
    return await _dataSource.deleteSubmission(submissionId);
  }

  @override
  Future<Submission?> getSubmissionById(String submissionId) async {
    return await _dataSource.getSubmissionById(submissionId);
  }
}
