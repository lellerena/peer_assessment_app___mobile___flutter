import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/category.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/category_controller.dart';
import '../../domain/usecases/assessment_usecase.dart';
import '../../domain/usecases/category_usecase.dart';
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
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Almacenamiento local para evaluaciones (fallback)
  static final Map<String, List<Assessment>> _localAssessments = {};
  static final Map<String, String> _assessmentStates = {}; // assessmentId -> status

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _addAssessmentLocally(Assessment assessment) {
    // Agregar evaluación al almacenamiento local
    if (!_localAssessments.containsKey(widget.course.id)) {
      _localAssessments[widget.course.id] = [];
    }
    _localAssessments[widget.course.id]!.add(assessment);
    
    // Actualizar la UI
    setState(() {
      _assessments = List.from(_localAssessments[widget.course.id]!);
    });
  }

  void _activateAssessmentLocally(String assessmentId) {
    // Activar evaluación en almacenamiento local
    _assessmentStates[assessmentId] = 'active';
    
    // Actualizar la evaluación en la lista local
    final courseAssessments = _localAssessments[widget.course.id];
    if (courseAssessments != null) {
      for (int i = 0; i < courseAssessments.length; i++) {
        if (courseAssessments[i].id == assessmentId) {
          courseAssessments[i] = Assessment(
            id: courseAssessments[i].id,
            name: courseAssessments[i].name,
            description: courseAssessments[i].description,
            courseId: courseAssessments[i].courseId,
            categoryId: courseAssessments[i].categoryId,
            status: AssessmentStatus.active,
            visibility: courseAssessments[i].visibility,
            criteria: courseAssessments[i].criteria,
            startDate: DateTime.now(),
            endDate: courseAssessments[i].endDate,
            createdAt: courseAssessments[i].createdAt,
            updatedAt: DateTime.now(),
          );
          break;
        }
      }
    }
    
    // Actualizar la UI
    setState(() {
      _assessments = List.from(_localAssessments[widget.course.id]!);
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Cargar categorías (con fallback a datos locales)
      List<Category> categories = [];
      try {
        final categoryUseCase = Get.find<CategoryUseCase>();
        print("Loading categories for course: ${widget.course.id}");
        categories = await categoryUseCase.getCategoriesByCourseId(widget.course.id);
        print("Found ${categories.length} categories from remote");
      } catch (e) {
        print("Error loading categories from remote, using local data: $e");
        // Fallback a datos locales si Roble falla
        categories = await _loadLocalCategories();
        print("Found ${categories.length} categories from local");
      }
      
      // Cargar evaluaciones (con manejo de error 500 y fallback local)
      List<Assessment> assessments = [];
      try {
        final assessmentUseCase = Get.find<AssessmentUseCase>();
        assessments = await assessmentUseCase.getAssessmentsByCourseId(widget.course.id);
      } catch (e) {
        print("Error loading assessments from Roble, using local storage: $e");
        // Usar almacenamiento local como fallback
        assessments = _localAssessments[widget.course.id] ?? [];
      }

      setState(() {
        _categories = categories;
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading assessment data: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Error loading data: $e";
        _categories = [];
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

  void _showAddEditDialog([Assessment? assessment]) {
    if (_categories.isEmpty) {
      Get.snackbar(
        'Categorías Requeridas',
        'Debes crear al menos una categoría antes de crear evaluaciones',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddEditAssessmentDialog(
        assessment: assessment,
        courseId: widget.course.id,
        categories: _categories,
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
      final assessmentUseCase = Get.find<AssessmentUseCase>();
      await assessmentUseCase.addAssessment(assessment);
      
      // Agregar también al almacenamiento local
      _addAssessmentLocally(assessment);
      
      Get.snackbar(
        'Éxito',
        'Evaluación creada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding assessment to Roble, using local storage: $e");
      
      // Fallback: agregar al almacenamiento local
      _addAssessmentLocally(assessment);
      
      Get.snackbar(
        'Éxito',
        'Evaluación creada (almacenada localmente)',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateAssessment(Assessment assessment) async {
    try {
      final assessmentUseCase = Get.find<AssessmentUseCase>();
      await assessmentUseCase.updateAssessment(assessment);
      await _loadData();
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
      final assessmentUseCase = Get.find<AssessmentUseCase>();
      await assessmentUseCase.deleteAssessment(assessment.id);
      await _loadData();
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
      final assessmentUseCase = Get.find<AssessmentUseCase>();
      await assessmentUseCase.activateAssessment(assessment.id);
      
      // También activar localmente
      _activateAssessmentLocally(assessment.id);
      
      Get.snackbar(
        'Éxito',
        'Evaluación activada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error activating assessment in Roble, using local fallback: $e");
      
      // Fallback: activar localmente
      _activateAssessmentLocally(assessment.id);
      
      Get.snackbar(
        'Éxito',
        'Evaluación activada (almacenada localmente)',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deactivateAssessment(Assessment assessment) async {
    try {
      final assessmentUseCase = Get.find<AssessmentUseCase>();
      await assessmentUseCase.deactivateAssessment(assessment.id);
      await _loadData();
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
