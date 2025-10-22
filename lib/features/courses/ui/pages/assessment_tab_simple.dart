import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/category.dart';
import '../../domain/models/activity.dart'; // NUEVO: Importar Activity
import '../controllers/assessment_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/activity_controller.dart'; // NUEVO: Importar ActivityController
import '../../domain/usecases/assessment_usecase.dart';
import '../../domain/usecases/category_usecase.dart';
import '../../domain/usecases/activity_usecase.dart'; // NUEVO: Importar ActivityUseCase
import '../widgets/assessment_list_tile.dart';
import '../widgets/add_edit_assessment_dialog.dart';
import '../pages/student_assessment_page.dart';
import '../pages/assessment_results_page.dart';
import '../../../../core/i_local_preferences.dart';

class AssessmentTabSimple extends StatefulWidget {
  final Course course;
  final bool isTeacher;

  const AssessmentTabSimple({
    Key? key,
    required this.course,
    required this.isTeacher,
  }) : super(key: key);

  @override
  State<AssessmentTabSimple> createState() => _AssessmentTabSimpleState();
}

class _AssessmentTabSimpleState extends State<AssessmentTabSimple> {
  List<Assessment> _assessments = [];
  List<Category> _categories = [];
  List<Activity> _activities = []; // NUEVO: Lista de actividades
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Controladores para Roble
  late AssessmentController _assessmentController;
  late CategoryController _categoryController;
  late ActivityController _activityController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    // Usar tags específicos para este curso
    final String courseId = widget.course.id;
    final String categoryTag = 'category_controller_$courseId';
    final String activityTag = 'activity_controller_$courseId';
    final String assessmentTag = 'assessment_controller_$courseId';
    
    // Crear o obtener controladores con tags específicos
    if (!Get.isRegistered<CategoryController>(tag: categoryTag)) {
      Get.put(
        CategoryController(Get.find<CategoryUseCase>(), courseId),
        tag: categoryTag,
      );
    }
    
    if (!Get.isRegistered<ActivityController>(tag: activityTag)) {
      Get.put(
        ActivityController(Get.find<ActivityUseCase>(), courseId),
        tag: activityTag,
      );
    }
    
    if (!Get.isRegistered<AssessmentController>(tag: assessmentTag)) {
      Get.put(
        AssessmentController(Get.find<AssessmentUseCase>(), Get.find<CategoryUseCase>(), courseId),
        tag: assessmentTag,
      );
    }
    
    // Obtener las instancias
    _categoryController = Get.find<CategoryController>(tag: categoryTag);
    _activityController = Get.find<ActivityController>(tag: activityTag);
    _assessmentController = Get.find<AssessmentController>(tag: assessmentTag);
  }

  Future<List<Category>> _loadLocalCategories() async {
    // Cargar categorías desde el archivo JSON local
    try {
      final String categoriesJson = await DefaultAssetBundle.of(context)
          .loadString('assets/data/categories.json');
      final List<dynamic> categoriesData = json.decode(categoriesJson);
      
      return categoriesData
          .where((category) => category['courseId'] == widget.course.id)
          .map((category) => Category.fromJson(category))
          .toList();
    } catch (e) {
      print("Error loading local categories: $e");
      return [];
    }
  }

  // NUEVO: Cargar actividades locales
  Future<List<Activity>> _loadLocalActivities() async {
    try {
      final String activitiesJson = await DefaultAssetBundle.of(context)
          .loadString('assets/data/activities.json');
      final List<dynamic> activitiesData = json.decode(activitiesJson);
      
      return activitiesData
          .where((activity) => activity['courseId'] == widget.course.id)
          .map((activity) => Activity.fromJson(activity))
          .toList();
    } catch (e) {
      print("Error loading local activities: $e");
      return [];
    }
  }


  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Cargar datos desde Roble usando controladores
      await Future.wait([
        _categoryController.getCategories(),
        _activityController.getActivities(),
        _assessmentController.getAssessments(),
      ]);

      setState(() {
        _categories = _categoryController.categories;
        _activities = _activityController.activities;
        _assessments = _assessmentController.assessments;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data from Roble: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Error loading data: $e";
        _categories = [];
        _activities = [];
        _assessments = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header con contador y botón de reload
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Evaluaciones (${_assessments.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Recargar',
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          // Contenido de evaluaciones
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: widget.isTeacher
          ? FloatingActionButton(
              heroTag: "assessment_simple_fab_${widget.course.id}",
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: _showAddEditDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_assessments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 60,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay evaluaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isTeacher
                  ? 'Crea una nueva evaluación para este curso'
                  : 'No hay evaluaciones disponibles para este curso',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _assessments.length,
      itemBuilder: (context, index) {
        final assessment = _assessments[index];
        final category = _categories.firstWhereOrNull(
          (c) => c.id == assessment.categoryId,
        );
        
        return AssessmentListTile(
          assessment: assessment,
          categoryName: category?.name,
          onEdit: widget.isTeacher
              ? () => _showAddEditDialog(assessment)
              : null,
          onDelete: widget.isTeacher
              ? () => _showDeleteConfirmation(assessment)
              : null,
          onActivate: widget.isTeacher
              ? () => _activateAssessment(assessment)
              : null,
          onDeactivate: widget.isTeacher
              ? () => _deactivateAssessment(assessment)
              : null,
          onViewResults: widget.isTeacher
              ? () => _viewResults(assessment)
              : null,
          onStartEvaluation: !widget.isTeacher
              ? () => _startEvaluation(assessment)
              : null,
          isTeacher: widget.isTeacher,
          canEvaluate: !widget.isTeacher && assessment.status == AssessmentStatus.active,
        );
      },
    );
  }

  void _showAddEditDialog([Assessment? assessment]) async {
    if (_categories.isEmpty) {
      Get.snackbar(
        'Categorías Requeridas',
        'Debes crear al menos una categoría antes de crear evaluaciones',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Refrescar categorías y actividades antes de abrir el diálogo
    await Future.wait([
      _categoryController.getCategories(),
      _activityController.getActivities(),
    ]);
    
    setState(() {
      _categories = _categoryController.categories;
      _activities = _activityController.activities;
    });

    showDialog(
      context: context,
      builder: (context) => AddEditAssessmentDialog(
        assessment: assessment,
        courseId: widget.course.id,
        categories: _categories,
        activities: _activities,
        onSave: (newAssessment) {
          if (assessment == null) {
            _addAssessment(newAssessment);
          } else {
            _updateAssessment(newAssessment);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Assessment assessment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar "${assessment.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                _deleteAssessment(assessment);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAssessment(Assessment assessment) async {
    try {
      await _assessmentController.addAssessment(assessment);
      await _loadData(); // Recargar datos desde Roble
      
      Get.snackbar(
        'Éxito',
        'Evaluación creada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding assessment: $e");
      Get.snackbar(
        'Error',
        'No se pudo crear la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateAssessment(Assessment assessment) async {
    try {
      await _assessmentController.updateAssessment(assessment);
      await _loadData(); // Recargar datos desde Roble
      
      Get.snackbar(
        'Éxito',
        'Evaluación actualizada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error updating assessment: $e");
      Get.snackbar(
        'Error',
        'No se pudo actualizar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteAssessment(Assessment assessment) async {
    try {
      await _assessmentController.deleteAssessment(assessment.id);
      await _loadData(); // Recargar datos desde Roble
      
      Get.snackbar(
        'Éxito',
        'Evaluación eliminada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deleting assessment: $e");
      Get.snackbar(
        'Error',
        'No se pudo eliminar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _activateAssessment(Assessment assessment) async {
    try {
      await _assessmentController.activateAssessment(assessment.id);
      await _loadData(); // Recargar datos desde Roble
      
      Get.snackbar(
        'Éxito',
        'Evaluación activada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error activating assessment: $e");
      Get.snackbar(
        'Error',
        'No se pudo activar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deactivateAssessment(Assessment assessment) async {
    try {
      await _assessmentController.deactivateAssessment(assessment.id);
      await _loadData(); // Recargar datos desde Roble
      
      Get.snackbar(
        'Éxito',
        'Evaluación desactivada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deactivating assessment: $e");
      Get.snackbar(
        'Error',
        'No se pudo desactivar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _viewResults(Assessment assessment) {
    Get.to(() => AssessmentResultsPage(assessment: assessment));
  }

  Future<void> _startEvaluation(Assessment assessment) async {
    try {
      // Obtener información del estudiante actual
      final prefs = Get.find<ILocalPreferences>();
      final rawUser = await prefs.retrieveData<String>('user');
      
      if (rawUser == null) {
        Get.snackbar(
          'Error',
          'No se pudo obtener la información del usuario',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final userData = json.decode(rawUser);
      final studentId = userData['id'] as String?;
      
      if (studentId == null) {
        Get.snackbar(
          'Error',
          'ID de usuario no válido',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Buscar el grupo del estudiante en la categoría
      final category = _categories.firstWhereOrNull(
        (c) => c.id == assessment.categoryId,
      );

      if (category == null) {
        Get.snackbar(
          'Error',
          'No se encontró la categoría de la evaluación',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final studentGroup = category.groups.firstWhereOrNull(
        (group) => group.studentIds.contains(studentId),
      );

      if (studentGroup == null) {
        Get.snackbar(
          'Sin Grupo',
          'No estás asignado a un grupo en esta categoría',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Navegar a la página de evaluación
      Get.to(() => StudentAssessmentPage(
        assessment: assessment,
        studentId: studentId,
        groupId: studentGroup.id,
        categoryId: category.id,
      ));
    } catch (e) {
      print("Error starting evaluation: $e");
      Get.snackbar(
        'Error',
        'No se pudo iniciar la evaluación: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
