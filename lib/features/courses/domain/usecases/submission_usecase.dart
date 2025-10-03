import '../models/submission.dart';
import '../repositories/i_submission_repository.dart';

class SubmissionUseCase {
  final ISubmissionRepository _repository;

  SubmissionUseCase(this._repository);

  Future<List<Submission>> getSubmissionsByActivityId(
    String activityId,
  ) async => await _repository.getSubmissionsByActivityId(activityId);

  Future<List<Submission>> getSubmissionsByStudentId(String studentId) async =>
      await _repository.getSubmissionsByStudentId(studentId);

  Future<List<Submission>> getSubmissionsByGroupId(String groupId) async =>
      await _repository.getSubmissionsByGroupId(groupId);

  Future<List<Submission>> getSubmissionsByCourseId(String courseId) async =>
      await _repository.getSubmissionsByCourseId(courseId);

  Future<bool> addSubmission(Submission submission) async =>
      await _repository.addSubmission(submission);

  Future<bool> updateSubmission(Submission submission) async =>
      await _repository.updateSubmission(submission);

  Future<bool> deleteSubmission(String submissionId) async =>
      await _repository.deleteSubmission(submissionId);

  Future<Submission?> getSubmissionById(String submissionId) async =>
      await _repository.getSubmissionById(submissionId);
}
