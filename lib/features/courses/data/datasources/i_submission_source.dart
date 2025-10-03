import '../../domain/models/submission.dart';

abstract class ISubmissionDataSource {
  Future<List<Submission>> getSubmissionsByActivityId(String activityId);
  Future<List<Submission>> getSubmissionsByStudentId(String studentId);
  Future<List<Submission>> getSubmissionsByGroupId(String groupId);
  Future<List<Submission>> getSubmissionsByCourseId(String courseId);
  Future<bool> addSubmission(Submission submission);
  Future<bool> updateSubmission(Submission submission);
  Future<bool> deleteSubmission(String submissionId);
  Future<Submission?> getSubmissionById(String submissionId);
}
