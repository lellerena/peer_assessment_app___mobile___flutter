enum AssessmentStatus { draft, active, completed, cancelled }

enum AssessmentVisibility { public, private }

enum ScaleType { stars, numeric, binary, comment }

class Assessment {
  final String id;
  final String name;
  final String description;
  final String courseId;
  final String activityId; // Cambiado de categoryId a activityId
  final AssessmentStatus status;
  final AssessmentVisibility visibility;
  final int durationValue; // Nuevo campo para duración
  final String durationUnit; // Nuevo campo para unidad de duración
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AssessmentCriteria> criteria;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Assessment({
    required this.id,
    required this.name,
    required this.description,
    required this.courseId,
    required this.activityId, // Cambiado de categoryId a activityId
    required this.status,
    required this.visibility,
    required this.durationValue, // Nuevo campo requerido
    required this.durationUnit, // Nuevo campo requerido
    this.startDate,
    this.endDate,
    required this.criteria,
    required this.createdAt,
    this.updatedAt,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      courseId: json['courseId'] ?? '',
      activityId: json['activityId'] ?? '', // Cambiado de categoryId a activityId
      status: AssessmentStatus.values.firstWhere(
        (e) => e.toString() == 'AssessmentStatus.${json['status']}',
        orElse: () => AssessmentStatus.draft,
      ),
      visibility: AssessmentVisibility.values.firstWhere(
        (e) => e.toString() == 'AssessmentVisibility.${json['visibility']}',
        orElse: () => AssessmentVisibility.private,
      ),
      durationValue: json['duration_value'] ?? 60, // Nuevo campo con valor por defecto
      durationUnit: json['duration_unit'] ?? 'minutes', // Nuevo campo con valor por defecto
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      criteria: json['criteria'] != null && json['criteria'].containsKey('data')
          ? List<AssessmentCriteria>.from(
              (json['criteria']['data'] as List).map((c) => AssessmentCriteria.fromJson(c)),
            )
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'courseId': courseId,
      'activityId': activityId, // Cambiado de categoryId a activityId
      'status': status.name,
      'visibility': visibility.name,
      'duration_value': durationValue, // Nuevo campo
      'duration_unit': durationUnit, // Nuevo campo
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'criteria': {'data': criteria.map((c) => c.toJson()).toList()},
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonNoId() {
    return {
      'name': name,
      'description': description,
      'courseId': courseId,
      'activityId': activityId, // Cambiado de categoryId a activityId
      'status': status.name,
      'visibility': visibility.name,
      'duration_value': durationValue, // Nuevo campo
      'duration_unit': durationUnit, // Nuevo campo
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'criteria': {'data': criteria.map((c) => c.toJson()).toList()},
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Assessment{id: $id, name: $name, status: $status, courseId: $courseId, activityId: $activityId}';
  }
}

class AssessmentCriteria {
  final String id;
  final String name;
  final String description;
  final ScaleType scaleType;
  final bool isRequired;
  final Map<String, dynamic>? scaleConfig; // Para configuraciones específicas de cada tipo

  AssessmentCriteria({
    required this.id,
    required this.name,
    required this.description,
    required this.scaleType,
    required this.isRequired,
    this.scaleConfig,
  });

  factory AssessmentCriteria.fromJson(Map<String, dynamic> json) {
    return AssessmentCriteria(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      scaleType: ScaleType.values.firstWhere(
        (e) => e.toString() == 'ScaleType.${json['scaleType']}',
        orElse: () => ScaleType.stars,
      ),
      isRequired: json['isRequired'] ?? true,
      scaleConfig: json['scaleConfig'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'scaleType': scaleType.name,
      'isRequired': isRequired,
      'scaleConfig': scaleConfig,
    };
  }

  @override
  String toString() {
    return 'AssessmentCriteria{id: $id, name: $name, scaleType: $scaleType, isRequired: $isRequired}';
  }
}
