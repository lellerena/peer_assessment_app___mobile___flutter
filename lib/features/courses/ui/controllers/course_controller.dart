import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/usecases/course_usecase.dart';
import '../../../../../core/i_local_preferences.dart';

class CourseController extends GetxController {
  final CourseUseCase usecase;
  CourseController(this.usecase);

  final allCourses = <Course>[].obs;
  final teacherCourses = <Course>[].obs;
  final loading = false.obs;
  final ILocalPreferences sharedPreferences = Get.find();

  @override
  void onInit() {
    super.onInit();
    getAllCourses();
    getTeacherCourses();
  }

  Future<void> refreshCourses() async {
    await getAllCourses();
    await getTeacherCourses();
  }

  @override
  void onClose() {
    super.onClose();
    allCourses.clear();
    teacherCourses.clear();
    loading.value = false;
    enrolledUserIds.clear();
  }

  Future<void> getAllCourses() async {
    loading.value = true;
    allCourses.value = await usecase.getAll();
    loading.value = false;
  }

  Future<void> getTeacherCourses() async {
    final teacherId = await sharedPreferences.retrieveData<String>('userId');
    if (teacherId == null) return;
    loading.value = true;
    final all = await usecase.getAll();
    teacherCourses.value = all.where((c) => c.teacherId == teacherId).toList();
    loading.value = false;
  }

  Future<void> addCourse(String name, String desc) async {
    final teacherId = await sharedPreferences.retrieveData<String>('userId');
    if (teacherId == null) return;
    await usecase.addCourse(
      Course(
        id: '',
        name: name,
        description: desc,
        categoryIds: [],
        teacherId: teacherId,
      ),
    );
    await getTeacherCourses();
  }

  Future<void> enroll(String courseId) async {
    final userId = await sharedPreferences.retrieveData<String>('userId');
    if (userId == null) return;
    await usecase.enrollUser(courseId, userId);
    await getAllCourses(); // Recarga para actualizar el estado del botón
  }

  final enrolledUserIds = <String>[].obs;

  Future<void> loadEnrolled(String courseId) async {
    enrolledUserIds.value = await usecase.getEnrolledUserIds(courseId);
  }

  // Verificar si el usuario actual está inscrito en un curso
  Future<bool> isUserEnrolled(String courseId) async {
    final userId = await sharedPreferences.retrieveData<String>('userId');
    if (userId == null) return false;
    
    final enrolledIds = await usecase.getEnrolledUserIds(courseId);
    return enrolledIds.contains(userId);
  }

  // Obtener información de usuarios por IDs (versión simplificada)
  Future<List<Map<String, String>>> getUsersByIds(List<String> userIds) async {
    try {
      // Por ahora, devolvemos información básica basada en los IDs
      // En el futuro se puede integrar con la API de usuarios
      return userIds.map((id) => {
        'id': id,
        'name': _generateDisplayName(id),
        'email': id, // Usar el ID como email temporalmente
      }).toList();
    } catch (e) {
      print("Error getting users by IDs: $e");
      return [];
    }
  }

  // Generar un nombre de visualización basado en el ID
  String _generateDisplayName(String userId) {
    // Si el ID parece ser un email, usar la parte antes del @ y formatear
    if (userId.contains('@')) {
      final emailPart = userId.split('@')[0];
      // Convertir puntos y guiones bajos a espacios y capitalizar
      return emailPart
          .replaceAll('.', ' ')
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
          .join(' ');
    }
    
    // Si es un UUID, intentar extraer información útil
    if (userId.length > 8) {
      // Para UUIDs, usar las primeras 8 caracteres como identificador
      return 'Usuario ${userId.substring(0, 8)}';
    }
    
    return 'Usuario $userId';
  }
}
