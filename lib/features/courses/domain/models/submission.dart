class Submission {
  final String id;
  final String studentId;
  final String activityId;
  final String groupId;
  final String content;
  final DateTime submissionDate;
  final String? grade;
  final String? feedback;
  final String courseId;

  Submission({
    required this.id,
    required this.studentId,
    required this.activityId,
    required this.groupId,
    required this.content,
    required this.submissionDate,
    this.grade,
    this.feedback,
    required this.courseId,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['_id'] ?? json['id'],
      studentId: json['studentId'],
      activityId: json['activityId'],
      groupId: json['groupId'],
      content: json['content'],
      submissionDate: DateTime.parse(json['submissionDate']),
      grade: json['grade'],
      feedback: json['feedback'],
      courseId: json['courseId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Usamos '_id' como clave para la API
      '_id': id,
      'studentId': studentId,
      'activityId': activityId,
      'groupId': groupId,
      'content': content,
      'submissionDate': submissionDate.toIso8601String(),
      'grade': grade,
      'feedback': feedback,
      'courseId': courseId,
    };
  }

  Map<String, dynamic> toJsonNoId() {
    return {
      'studentId': studentId,
      'activityId': activityId,
      'groupId': groupId,
      'content': content,
      'submissionDate': submissionDate.toIso8601String(),
      'grade': grade,
      'feedback': feedback,
      'courseId': courseId,
    };
  }

  @override
  String toString() {
    return 'Submission{id: $id, studentId: $studentId, activityId: $activityId, groupId: $groupId, content: $content, submissionDate: $submissionDate, grade: $grade, feedback: $feedback, courseId: $courseId}';
  }
}
