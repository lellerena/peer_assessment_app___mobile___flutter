import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/assessment.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/course_controller.dart';

class AssessmentResultsPage extends StatefulWidget {
  final Assessment assessment;

  const AssessmentResultsPage({
    Key? key,
    required this.assessment,
  }) : super(key: key);

  @override
  State<AssessmentResultsPage> createState() => _AssessmentResultsPageState();
}

class _AssessmentResultsPageState extends State<AssessmentResultsPage> {
  late AssessmentController _assessmentController;
  Map<String, dynamic> _results = {};
  List<Map<String, String>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadResults();
  }

  void _initializeController() {
    final String assessmentTag = 'assessment_controller_${widget.assessment.courseId}';
    _assessmentController = Get.find<AssessmentController>(tag: assessmentTag);
  }

  Future<void> _loadResults() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Obtener resultados de la evaluación
      final results = await _assessmentController.getAssessmentResults(widget.assessment.id);
      
      // Obtener información de estudiantes
      final courseController = Get.find<CourseController>();
      final allStudents = await courseController.getUsersByIds(
        results.keys.toList(),
      );

      setState(() {
        _results = results;
        _students = allStudents;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading assessment results: $e");
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'No se pudieron cargar los resultados',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Resultados: ${widget.assessment.name}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadResults,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildResultsContent(),
    );
  }

  Widget _buildResultsContent() {
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No hay resultados disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Los resultados aparecerán aquí una vez que los estudiantes completen las evaluaciones',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen general
          _buildSummaryCard(),
          const SizedBox(height: 24),
          // Lista de estudiantes con sus resultados
          Text(
            'Resultados por Estudiante',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildStudentResults(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalStudents = _results.length;
    final totalEvaluations = _results.values
        .map((result) => result['totalEvaluations'] as int)
        .fold(0, (sum, count) => sum + count);
    final averageEvaluations = totalStudents > 0 ? totalEvaluations / totalStudents : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Estudiantes Evaluados',
                  totalStudents.toString(),
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Evaluaciones',
                  totalEvaluations.toString(),
                  Icons.rate_review,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Promedio por Estudiante',
                  averageEvaluations.toStringAsFixed(1),
                  Icons.analytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildStudentResults() {
    return _results.entries.map((entry) {
      final studentId = entry.key;
      final result = entry.value;
      final studentInfo = _students.firstWhereOrNull(
        (s) => s['id'] == studentId,
      );
      
      final studentName = studentInfo?['name'] ?? 'Estudiante $studentId';
      final criteriaAverages = result['criteriaAverages'] as Map<String, double>;
      final totalEvaluations = result['totalEvaluations'] as int;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                child: Text(
                  studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$totalEvaluations evaluaciones recibidas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPerformanceColor(criteriaAverages).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPerformanceColor(criteriaAverages).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getOverallRating(criteriaAverages),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getPerformanceColor(criteriaAverages),
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calificaciones por Criterio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...criteriaAverages.entries.map((criteriaEntry) {
                    final criteriaId = criteriaEntry.key;
                    final average = criteriaEntry.value;
                    
                    // Buscar el criterio en la evaluación
                    final criteria = widget.assessment.criteria.firstWhereOrNull(
                      (c) => c.id == criteriaId,
                    );
                    
                    final criteriaName = criteria?.name ?? 'Criterio $criteriaId';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              criteriaName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _buildRatingDisplay(average, criteria?.scaleType),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showDetailedResults(studentId, result),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Ver Detalles'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildRatingDisplay(double average, ScaleType? scaleType) {
    switch (scaleType) {
      case ScaleType.stars:
        return Row(
          children: [
            ...List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = average >= starIndex;
              return Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
            const SizedBox(width: 8),
            Text(
              average.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case ScaleType.numeric:
        return Text(
          '${average.toStringAsFixed(1)}/100',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      case ScaleType.binary:
        return Text(
          average >= 0.5 ? 'Sí' : 'No',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: average >= 0.5 ? Colors.green : Colors.red,
          ),
        );
      case ScaleType.comment:
        return const Text(
          'Comentario',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        );
      default:
        return Text(
          average.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  Color _getPerformanceColor(Map<String, double> criteriaAverages) {
    if (criteriaAverages.isEmpty) return Colors.grey;
    
    final overallAverage = criteriaAverages.values.reduce((a, b) => a + b) / criteriaAverages.length;
    
    if (overallAverage >= 4.0) return Colors.green;
    if (overallAverage >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String _getOverallRating(Map<String, double> criteriaAverages) {
    if (criteriaAverages.isEmpty) return 'Sin datos';
    
    final overallAverage = criteriaAverages.values.reduce((a, b) => a + b) / criteriaAverages.length;
    
    if (overallAverage >= 4.0) return 'Excelente';
    if (overallAverage >= 3.0) return 'Bueno';
    if (overallAverage >= 2.0) return 'Regular';
    return 'Necesita mejorar';
  }

  void _showDetailedResults(String studentId, Map<String, dynamic> result) {
    final responses = result['responses'] as List<dynamic>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Evaluación'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final response = responses[index];
              return ListTile(
                title: Text('Evaluado por: ${response['evaluatorId']}'),
                subtitle: Text('Fecha: ${response['submittedAt']}'),
                trailing: response['comment'] != null 
                    ? const Icon(Icons.comment)
                    : null,
                onTap: () {
                  // Mostrar detalles de la respuesta específica
                  _showResponseDetails(response);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showResponseDetails(Map<String, dynamic> response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la Evaluación'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Evaluador: ${response['evaluatorId']}'),
              Text('Evaluado: ${response['evaluatedId']}'),
              Text('Fecha: ${response['submittedAt']}'),
              if (response['comment'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Comentario:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(response['comment']),
              ],
              const SizedBox(height: 16),
              const Text(
                'Criterios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...(response['criteriaResponses'] as List).map((criteria) {
                return ListTile(
                  title: Text('Criterio: ${criteria['criteriaId']}'),
                  subtitle: Text('Valor: ${criteria['value']}'),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
