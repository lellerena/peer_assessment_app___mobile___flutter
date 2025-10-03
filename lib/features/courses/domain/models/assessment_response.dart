class AssessmentResponse {
  final String id;
  final String assessmentId;
  final String evaluatorId; // Quién evalúa
  final String evaluatedId; // A quién evalúa
  final String courseId;
  final String groupId;
  final String categoryId;
  final List<CriteriaResponse> criteriaResponses;
  final String? comment;
  final DateTime submittedAt;
  final DateTime? updatedAt;

  AssessmentResponse({
    required this.id,
    required this.assessmentId,
    required this.evaluatorId,
    required this.evaluatedId,
    required this.courseId,
    required this.groupId,
    required this.categoryId,
    required this.criteriaResponses,
    this.comment,
    required this.submittedAt,
    this.updatedAt,
  });

  factory AssessmentResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentResponse(
      id: json['_id'] ?? json['id'],
      assessmentId: json['assessmentId'] ?? '',
      evaluatorId: json['evaluatorId'] ?? '',
      evaluatedId: json['evaluatedId'] ?? '',
      courseId: json['courseId'] ?? '',
      groupId: json['groupId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      criteriaResponses: json['criteriaResponses'] != null && json['criteriaResponses'].containsKey('data')
          ? List<CriteriaResponse>.from(
              (json['criteriaResponses']['data'] as List).map((c) => CriteriaResponse.fromJson(c)),
            )
          : [],
      comment: json['comment'],
      submittedAt: DateTime.parse(json['submittedAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'assessmentId': assessmentId,
      'evaluatorId': evaluatorId,
      'evaluatedId': evaluatedId,
      'courseId': courseId,
      'groupId': groupId,
      'categoryId': categoryId,
      'criteriaResponses': {'data': criteriaResponses.map((c) => c.toJson()).toList()},
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonNoId() {
    return {
      'assessmentId': assessmentId,
      'evaluatorId': evaluatorId,
      'evaluatedId': evaluatedId,
      'courseId': courseId,
      'groupId': groupId,
      'categoryId': categoryId,
      'criteriaResponses': {'data': criteriaResponses.map((c) => c.toJson()).toList()},
      'comment': comment,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AssessmentResponse{id: $id, evaluatorId: $evaluatorId, evaluatedId: $evaluatedId, assessmentId: $assessmentId}';
  }
}

class CriteriaResponse {
  final String criteriaId;
  final dynamic value; // Puede ser int, double, String, bool según el tipo de escala
  final String? textValue; // Para comentarios adicionales

  CriteriaResponse({
    required this.criteriaId,
    required this.value,
    this.textValue,
  });

  factory CriteriaResponse.fromJson(Map<String, dynamic> json) {
    return CriteriaResponse(
      criteriaId: json['criteriaId'] ?? '',
      value: json['value'],
      textValue: json['textValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criteriaId': criteriaId,
      'value': value,
      'textValue': textValue,
    };
  }

  @override
  String toString() {
    return 'CriteriaResponse{criteriaId: $criteriaId, value: $value, textValue: $textValue}';
  }
}
