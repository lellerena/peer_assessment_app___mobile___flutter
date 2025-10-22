import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

/// Servicio para notificar cambios en las calificaciones
/// Permite que diferentes partes de la aplicación se comuniquen
/// cuando se actualizan las calificaciones
class GradeNotificationService extends GetxService {
  static GradeNotificationService get to => Get.find();
  
  // Observable para notificar cambios en calificaciones
  final RxString _gradeUpdateTrigger = ''.obs;
  
  // Stream para escuchar cambios
  Stream<String> get onGradeUpdated => _gradeUpdateTrigger.stream;
  
  /// Notificar que se ha actualizado una calificación
  void notifyGradeUpdated(String courseId, {String? activityId, String? studentId}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final notification = '$courseId|$activityId|$studentId|$timestamp';
    
    logInfo('Notificando actualización de calificación: $notification');
    _gradeUpdateTrigger.value = notification;
  }
  
  /// Notificar que se ha agregado una nueva calificación
  void notifyGradeAdded(String courseId, String activityId, String studentId) {
    notifyGradeUpdated(courseId, activityId: activityId, studentId: studentId);
  }
  
  /// Notificar que se ha actualizado una calificación existente
  void notifyGradeModified(String courseId, String activityId, String studentId) {
    notifyGradeUpdated(courseId, activityId: activityId, studentId: studentId);
  }
}
