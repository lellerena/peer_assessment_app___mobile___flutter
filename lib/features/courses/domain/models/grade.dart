class Grade {
  final String id;
  final String assessmentId;
  final String activityId;
  final String courseId;
  final String groupId;
  final String studentId;
  final Map<String, dynamic> criterias; // JSON con creatividad, presentación, contenido
  final double finalGrade;
  final String? feedback;
  final String gradedBy;
  final DateTime gradedAt;

  Grade({
    required this.id,
    required this.assessmentId,
    required this.activityId,
    required this.courseId,
    required this.groupId,
    required this.studentId,
    required this.criterias,
    required this.finalGrade,
    this.feedback,
    required this.gradedBy,
    required this.gradedAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['_id'] ?? json['id'],
      assessmentId: json['assessmentId'] ?? '',
      activityId: json['activityId'] ?? '',
      courseId: json['courseId'] ?? '',
      groupId: json['groupId'] ?? '',
      studentId: json['studentId'] ?? '',
      criterias: json['criterias'] ?? {},
      finalGrade: _parseDouble(json['finalGrade']),
      feedback: json['feedback'],
      gradedBy: json['gradedBy'] ?? '',
      gradedAt: DateTime.parse(json['gradedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'assessmentId': assessmentId,
      'activityId': activityId,
      'courseId': courseId,
      'groupId': groupId,
      'studentId': studentId,
      'criterias': criterias,
      'finalGrade': finalGrade,
      'feedback': feedback,
      'gradedBy': gradedBy,
      'gradedAt': gradedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonNoId() {
    return {
      'assessmentId': assessmentId,
      'activityId': activityId,
      'courseId': courseId,
      'groupId': groupId,
      'studentId': studentId,
      'criterias': criterias,
      'finalGrade': finalGrade,
      'feedback': feedback,
      'gradedBy': gradedBy,
      'gradedAt': gradedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Grade{id: $id, studentId: $studentId, finalGrade: $finalGrade, criterias: $criterias}';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
