import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/category.dart';
import '../../domain/models/group.dart';
import '../../domain/usecases/activity_usecase.dart';
import '../../domain/usecases/grade_usecase.dart';
import '../../domain/usecases/category_usecase.dart';
import '../../../../core/grade_notification_service.dart';

class ReportsController extends GetxController {
  final ActivityUseCase _activityUsecase;
  final GradeUsecase _gradeUsecase;
  final CategoryUseCase _categoryUseCase;
  final String courseId;

  ReportsController(this._activityUsecase, this._gradeUsecase, this._categoryUseCase, this.courseId);

  final RxList<Activity> activities = <Activity>[].obs;
  final RxList<Map<String, dynamic>> grades = <Map<String, dynamic>>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Group> allGroups = <Group>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadReportData();
    
    // Escuchar cambios en las calificaciones para actualizar automáticamente
    ever(grades, (_) {
      logInfo('Calificaciones actualizadas, refrescando reportes');
      // No necesitamos recargar todo, solo actualizar los datos calculados
    });
    
    // Escuchar notificaciones de cambios en calificaciones desde otras partes de la app
    GradeNotificationService.to.onGradeUpdated.listen((notification) {
      final parts = notification.split('|');
      if (parts.length >= 1 && parts[0] == courseId) {
        logInfo('Recibida notificación de actualización de calificación para curso: $courseId');
        // Recargar solo las calificaciones para este curso
        _loadGrades();
      }
    });
  }

  Future<void> loadReportData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      logInfo('Cargando datos para reportes del curso: $courseId');
      
      // Cargar actividades del curso
      await _loadActivities();
      
      // Cargar categorías y grupos
      await _loadCategoriesAndGroups();
      
      // Cargar calificaciones para todas las actividades
      await _loadGrades();
      
      logInfo('Datos de reportes cargados: ${activities.length} actividades, ${grades.length} calificaciones');
      
    } catch (e) {
      errorMessage.value = 'Error al cargar datos de reportes: $e';
      logError('Error al cargar datos de reportes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadActivities() async {
    try {
      activities.value = await _activityUsecase.getActivitiesByCourseId(courseId);
      logInfo('Actividades cargadas: ${activities.length}');
    } catch (e) {
      logError('Error cargando actividades: $e');
      activities.value = [];
    }
  }

  Future<void> _loadCategoriesAndGroups() async {
    try {
      categories.value = await _categoryUseCase.getCategoriesByCourseId(courseId);
      
      // Extraer todos los grupos de todas las categorías
      allGroups.value = categories.expand((category) => category.groups).toList();
      
      logInfo('Categorías cargadas: ${categories.length}, Grupos: ${allGroups.length}');
    } catch (e) {
      logError('Error cargando categorías y grupos: $e');
      categories.value = [];
      allGroups.value = [];
    }
  }

  Future<void> _loadGrades() async {
    try {
      grades.value = [];
      
      // Cargar calificaciones para cada actividad
      for (final activity in activities) {
        try {
          final activityGrades = await _gradeUsecase.getGradesByActivityId(activity.id);
          // Convertir Grade objects a Map<String, dynamic>
          for (final grade in activityGrades) {
            grades.add(grade.toJson());
          }
        } catch (e) {
          logError('Error cargando calificaciones para actividad ${activity.id}: $e');
        }
      }
      
      logInfo('Calificaciones cargadas: ${grades.length}');
    } catch (e) {
      logError('Error cargando calificaciones: $e');
      grades.value = [];
    }
  }

  // Obtener calificaciones por actividad
  List<Map<String, dynamic>> getGradesForActivity(String activityId) {
    return grades.where((grade) => grade['activityId'] == activityId).toList();
  }

  // Obtener calificaciones por estudiante
  List<Map<String, dynamic>> getGradesForStudent(String studentId) {
    return grades.where((grade) => grade['studentId'] == studentId).toList();
  }

  // Obtener calificaciones por grupo
  List<Map<String, dynamic>> getGradesForGroup(String groupId) {
    return grades.where((grade) => grade['groupId'] == groupId).toList();
  }

  // Obtener promedio de calificaciones por actividad
  double getActivityAverage(String activityId) {
    final activityGrades = getGradesForActivity(activityId);
    if (activityGrades.isEmpty) return 0.0;
    
    final total = activityGrades.fold<double>(0.0, (sum, grade) {
      final finalGrade = grade['finalGrade'];
      if (finalGrade is num) {
        return sum + finalGrade.toDouble();
      }
      return sum;
    });
    
    return total / activityGrades.length;
  }

  // Obtener promedio de calificaciones por estudiante
  double getStudentAverage(String studentId) {
    final studentGrades = getGradesForStudent(studentId);
    if (studentGrades.isEmpty) return 0.0;
    
    final total = studentGrades.fold<double>(0.0, (sum, grade) {
      final finalGrade = grade['finalGrade'];
      if (finalGrade is num) {
        return sum + finalGrade.toDouble();
      }
      return sum;
    });
    
    return total / studentGrades.length;
  }

  // Obtener promedio de calificaciones por grupo
  double getGroupAverage(String groupId) {
    final groupGrades = getGradesForGroup(groupId);
    if (groupGrades.isEmpty) return 0.0;
    
    final total = groupGrades.fold<double>(0.0, (sum, grade) {
      final finalGrade = grade['finalGrade'];
      if (finalGrade is num) {
        return sum + finalGrade.toDouble();
      }
      return sum;
    });
    
    return total / groupGrades.length;
  }

  // Obtener estudiantes únicos que tienen calificaciones
  List<String> getStudentsWithGrades() {
    final studentIds = grades.map((grade) => grade['studentId'] as String? ?? '').toSet();
    return studentIds.where((id) => id.isNotEmpty).toList();
  }

  // Obtener grupos únicos que tienen calificaciones
  List<String> getGroupsWithGrades() {
    final groupIds = grades.map((grade) => grade['groupId'] as String? ?? '').toSet();
    return groupIds.where((id) => id.isNotEmpty).toList();
  }

  // Obtener calificación específica de un estudiante en una actividad
  double getStudentGradeForActivity(String studentId, String activityId) {
    final grade = grades.firstWhereOrNull((g) => 
      g['studentId'] == studentId && g['activityId'] == activityId
    );
    
    if (grade != null) {
      final finalGrade = grade['finalGrade'];
      if (finalGrade is num) {
        return finalGrade.toDouble();
      }
    }
    
    return 0.0; // Retornar 0 si no hay calificación
  }

  // Obtener información del grupo de un estudiante
  String? getStudentGroup(String studentId) {
    for (final category in categories) {
      for (final group in category.groups) {
        if (group.studentIds.contains(studentId)) {
          return group.name;
        }
      }
    }
    return null;
  }

  // Obtener información de la categoría de un grupo
  String? getGroupCategory(String groupId) {
    for (final category in categories) {
      if (category.groups.any((group) => group.id == groupId)) {
        return category.name;
      }
    }
    return null;
  }

  // Método para agregar una nueva calificación y actualizar reportes
  Future<void> addGrade(Map<String, dynamic> newGrade) async {
    try {
      grades.add(newGrade);
      logInfo('Nueva calificación agregada, reportes actualizados automáticamente');
    } catch (e) {
      logError('Error agregando calificación: $e');
    }
  }

  // Método para actualizar una calificación existente
  Future<void> updateGrade(String gradeId, Map<String, dynamic> updatedGrade) async {
    try {
      final index = grades.indexWhere((grade) => grade['_id'] == gradeId || grade['id'] == gradeId);
      if (index != -1) {
        grades[index] = updatedGrade;
        logInfo('Calificación actualizada, reportes refrescados');
      }
    } catch (e) {
      logError('Error actualizando calificación: $e');
    }
  }

  // Obtener criterios específicos de una calificación
  Map<String, double> getGradeCriteria(String studentId, String activityId) {
    final grade = grades.firstWhereOrNull((g) => 
      g['studentId'] == studentId && g['activityId'] == activityId
    );
    
    if (grade != null && grade['criterias'] is Map<String, dynamic>) {
      final criterias = grade['criterias'] as Map<String, dynamic>;
      return {
        'creatividad': _parseDouble(criterias['creatividad']),
        'contenido': _parseDouble(criterias['contenido']),
        'presentacion': _parseDouble(criterias['presentacion']),
      };
    }
    
    return {
      'creatividad': 0.0,
      'contenido': 0.0,
      'presentacion': 0.0,
    };
  }

  // Calcular promedio de criterios
  double calculateCriteriaAverage(Map<String, double> criterias) {
    final values = criterias.values.where((v) => v > 0).toList();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  // Helper para parsear números
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
