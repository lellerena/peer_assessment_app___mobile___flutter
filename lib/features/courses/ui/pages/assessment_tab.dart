import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/category.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/category_controller.dart';
import '../../domain/usecases/assessment_usecase.dart';
import '../../domain/usecases/category_usecase.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../widgets/assessment_list_tile.dart';
import '../widgets/add_edit_assessment_dialog.dart';
import '../pages/student_assessment_page.dart';
import '../pages/assessment_results_page.dart';
import '../../../../core/i_local_preferences.dart';

class AssessmentTab extends StatefulWidget {
  final Course course;
  final bool isTeacher;

  const AssessmentTab({
    Key? key,
    required this.course,
    required this.isTeacher,
  }) : super(key: key);

  @override
  State<AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<AssessmentTab> {
  late AssessmentController _assessmentController;
  late CategoryController _categoryController;
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  @override
  void dispose() {
    // Limpiar controladores si es necesario
    super.dispose();
  }

  void _initializeControllers() {
    final String assessmentTag = 'assessment_controller_${widget.course.id}';
    final String categoryTag = 'category_controller_${widget.course.id}';
    
    // Siempre crear nuevos controladores para evitar problemas de estado
    _assessmentController = AssessmentController(
      Get.find<AssessmentUseCase>(),
      Get.find<CategoryUseCase>(),
      widget.course.id,
    );
    Get.put(_assessmentController, tag: assessmentTag);
    
    _categoryController = CategoryController(
      Get.find<CategoryUseCase>(),
      Get.find<CategoryLocalDataSource>(),
      widget.course.id,
    );
    Get.put(_categoryController, tag: categoryTag);
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Verificar que los controladores estén disponibles
      if (_assessmentController == null || _categoryController == null) {
        throw Exception("Controllers not initialized");
      }

      // Cargar categorías y evaluaciones
      await Future.wait([
        _categoryController!.getCategories(),
        _assessmentController!.getAssessments(),
      ]);

      setState(() {
        _categories = _categoryController!.categories;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading assessment data: $e");
      setState(() {
        _isLoading = false;
        _categories = [];
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
                  child: GetBuilder<AssessmentController>(
                    builder: (_) {
                      return Obx(
                        () => Text(
                          'Evaluaciones (${_assessmentController.assessments.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
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
              heroTag: "assessment_fab_${widget.course.id}",
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: _showAddEditDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
            _assessmentController.addAssessment(newAssessment);
          } else {
            _assessmentController.updateAssessment(newAssessment);
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
                _assessmentController.deleteAssessment(assessment.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _activateAssessment(Assessment assessment) {
    _assessmentController.activateAssessment(assessment.id);
  }

  void _deactivateAssessment(Assessment assessment) {
    _assessmentController.deactivateAssessment(assessment.id);
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

      // Verificar que el estudiante puede evaluar
      final canEvaluate = await _assessmentController.canStudentSubmitResponse(
        studentId,
        assessment.id,
      );

      if (!canEvaluate) {
        Get.snackbar(
          'Evaluación No Disponible',
          'Esta evaluación no está disponible en este momento',
          backgroundColor: Colors.orange,
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

  Widget _buildContent() {
    // Verificar si los controladores están disponibles
    if (_assessmentController == null || _categoryController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Error de Inicialización',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No se pudieron cargar los controladores',
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GetBuilder<AssessmentController>(
      builder: (_) {
        return Obx(() {
          if (_assessmentController!.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_assessmentController!.errorMessage.value.isNotEmpty) {
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
                    _assessmentController!.errorMessage.value,
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

          if (_assessmentController!.assessments.isEmpty) {
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
            itemCount: _assessmentController!.assessments.length,
            itemBuilder: (context, index) {
              final assessment = _assessmentController!.assessments[index];
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
        });
      },
    );
  }
}
