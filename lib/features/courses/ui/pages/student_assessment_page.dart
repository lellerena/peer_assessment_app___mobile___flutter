import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/assessment_response.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/category_controller.dart';
import '../widgets/criteria_response_widget.dart';

class StudentAssessmentPage extends StatefulWidget {
  final Assessment assessment;
  final String studentId;
  final String groupId;
  final String activityId;

  const StudentAssessmentPage({
    Key? key,
    required this.assessment,
    required this.studentId,
    required this.groupId,
    required this.activityId,
  }) : super(key: key);

  @override
  State<StudentAssessmentPage> createState() => _StudentAssessmentPageState();
}

class _StudentAssessmentPageState extends State<StudentAssessmentPage> {
  late AssessmentController _assessmentController;
  late CategoryController _categoryController;
  
  List<String> _studentsToEvaluate = [];
  int _currentStudentIndex = 0;
  final Map<String, List<CriteriaResponse>> _responses = {};
  final Map<String, String?> _comments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadStudentsToEvaluate();
  }

  void _initializeControllers() {
    final String assessmentTag = 'assessment_controller_${widget.assessment.courseId}';
    final String categoryTag = 'category_controller_${widget.assessment.courseId}';
    
    _assessmentController = Get.find<AssessmentController>(tag: assessmentTag);
    _categoryController = Get.find<CategoryController>(tag: categoryTag);
  }

  Future<void> _loadStudentsToEvaluate() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener los estudiantes del grupo excluyendo al evaluador
      final categories = _categoryController.categories;
      final category = categories.firstWhere(
        (c) => c.id == widget.activityId,
        orElse: () => throw Exception('Category not found'),
      );
      
      final group = category.groups.firstWhere(
        (g) => g.id == widget.groupId,
        orElse: () => throw Exception('Group not found'),
      );

      // Filtrar estudiantes (excluir al evaluador)
      _studentsToEvaluate = group.studentIds
          .where((id) => id != widget.studentId)
          .toList();

      // Inicializar respuestas vacías para cada estudiante
      for (final studentId in _studentsToEvaluate) {
        _responses[studentId] = [];
        _comments[studentId] = null;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading students to evaluate: $e");
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'No se pudieron cargar los estudiantes a evaluar',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_studentsToEvaluate.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Evaluación'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'No hay estudiantes para evaluar',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'No hay otros estudiantes en tu grupo para evaluar',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Evaluación: ${widget.assessment.name}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso: ${_currentStudentIndex + 1} de ${_studentsToEvaluate.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${((_currentStudentIndex + 1) / _studentsToEvaluate.length * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStudentIndex + 1) / _studentsToEvaluate.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Current student evaluation
          Expanded(
            child: _buildCurrentStudentEvaluation(),
          ),
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStudentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStudent,
                      child: const Text('Anterior'),
                    ),
                  ),
                if (_currentStudentIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStudentIndex < _studentsToEvaluate.length - 1
                        ? _nextStudent
                        : _submitAllEvaluations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStudentIndex < _studentsToEvaluate.length - 1
                          ? 'Siguiente'
                          : 'Finalizar Evaluación',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStudentEvaluation() {
    if (_currentStudentIndex >= _studentsToEvaluate.length) {
      return const Center(
        child: Text('No hay más estudiantes para evaluar'),
      );
    }

    final currentStudentId = _studentsToEvaluate[_currentStudentIndex];
    final currentResponses = _responses[currentStudentId] ?? [];
    final currentComment = _comments[currentStudentId];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    'E${_currentStudentIndex + 1}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evaluando a:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Estudiante ${_currentStudentIndex + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Assessment criteria
          Text(
            'Criterios de Evaluación',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.assessment.criteria.map((criteria) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CriteriaResponseWidget(
                criteria: criteria,
                initialValue: _getInitialValueForCriteria(criteria.id, currentResponses),
                onChanged: (value) => _updateCriteriaResponse(
                  currentStudentId,
                  criteria.id,
                  value,
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          // Comment section
          TextFormField(
            initialValue: currentComment,
            decoration: const InputDecoration(
              labelText: 'Comentario adicional (opcional)',
              hintText: 'Agrega cualquier comentario sobre el desempeño de este estudiante...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              _comments[currentStudentId] = value.isEmpty ? null : value;
            },
          ),
        ],
      ),
    );
  }

  dynamic _getInitialValueForCriteria(String criteriaId, List<CriteriaResponse> responses) {
    final response = responses.firstWhereOrNull(
      (r) => r.criteriaId == criteriaId,
    );
    return response?.value;
  }

  void _updateCriteriaResponse(String studentId, String criteriaId, dynamic value) {
    setState(() {
      final responses = _responses[studentId] ?? [];
      
      // Remover respuesta existente si existe
      responses.removeWhere((r) => r.criteriaId == criteriaId);
      
      // Agregar nueva respuesta
      responses.add(CriteriaResponse(
        criteriaId: criteriaId,
        value: value,
      ));
      
      _responses[studentId] = responses;
    });
  }

  void _previousStudent() {
    if (_currentStudentIndex > 0) {
      setState(() {
        _currentStudentIndex--;
      });
    }
  }

  void _nextStudent() {
    if (_currentStudentIndex < _studentsToEvaluate.length - 1) {
      setState(() {
        _currentStudentIndex++;
      });
    }
  }

  Future<void> _submitAllEvaluations() async {
    try {
      // Verificar que todas las evaluaciones estén completas
      for (final studentId in _studentsToEvaluate) {
        final responses = _responses[studentId] ?? [];
        if (responses.length != widget.assessment.criteria.length) {
          Get.snackbar(
            'Evaluación Incompleta',
            'Debes evaluar todos los criterios para cada estudiante',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Mostrar diálogo de confirmación
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Evaluación'),
          content: const Text(
            '¿Estás seguro de que quieres enviar todas las evaluaciones? '
            'Una vez enviadas, no podrás modificarlas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Enviar'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Enviar todas las evaluaciones
      bool allSuccessful = true;
      for (final studentId in _studentsToEvaluate) {
        final success = await _assessmentController.submitAssessmentResponse(
          assessmentId: widget.assessment.id,
          evaluatorId: widget.studentId,
          evaluatedId: studentId,
          groupId: widget.groupId,
          activityId: widget.activityId,
          criteriaResponses: _responses[studentId] ?? [],
          comment: _comments[studentId],
        );

        if (!success) {
          allSuccessful = false;
        }
      }

      if (allSuccessful) {
        Get.snackbar(
          'Éxito',
          'Todas las evaluaciones han sido enviadas correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          'Algunas evaluaciones no se pudieron enviar',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error submitting evaluations: $e");
      Get.snackbar(
        'Error',
        'Error al enviar las evaluaciones: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
