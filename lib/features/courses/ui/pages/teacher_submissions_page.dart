import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/models/activity.dart';
import '../../domain/models/submission.dart';
import '../../domain/models/grade.dart';
import '../controllers/submission_controller.dart';
import '../controllers/grade_controller.dart';

class TeacherSubmissionsPage extends StatefulWidget {
  final Activity activity;

  const TeacherSubmissionsPage({Key? key, required this.activity})
    : super(key: key);

  @override
  State<TeacherSubmissionsPage> createState() => _TeacherSubmissionsPageState();
}

class _TeacherSubmissionsPageState extends State<TeacherSubmissionsPage> {
  final SubmissionController _controller = Get.find<SubmissionController>();
  final GradeController _gradeController = Get.find<GradeController>();

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    await _controller.getSubmissionsByActivityId(widget.activity.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entregas: ${widget.activity.title}')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.submissions.isEmpty) {
          return const Center(
            child: Text(
              'No hay entregas para esta actividad',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _controller.submissions.length,
          itemBuilder: (context, index) {
            final submission = _controller.submissions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () {
                  _showSubmissionDetails(submission);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estudiante ID: ${submission.studentId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (submission.grade != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Calificación: ${submission.grade}',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (submission.groupId.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Grupo ID: ${submission.groupId}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      Text(
                        'Enviado: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submissionDate)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        submission.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSubmissions,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _showSubmissionDetails(Submission submission) async {
    final TextEditingController feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );
    
    // Controladores para los criterios
    final TextEditingController creativityController = TextEditingController();
    final TextEditingController presentationController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    bool isLoading = false;
    bool isEditing = false;
    String? existingGradeId;

    // Verificar si ya existe una calificación para esta entrega
    try {
      await _gradeController.getGradesByActivityId(submission.activityId);
      final existingGrades = _gradeController.grades;
      final existingGrade = existingGrades.firstWhereOrNull(
        (grade) => grade.studentId == submission.studentId,
      );
      
      if (existingGrade != null) {
        // Cargar valores existentes
        creativityController.text = existingGrade.criterias['creatividad']?.toString() ?? '';
        presentationController.text = existingGrade.criterias['presentacion']?.toString() ?? '';
        contentController.text = existingGrade.criterias['contenido']?.toString() ?? '';
        feedbackController.text = existingGrade.feedback ?? '';
        existingGradeId = existingGrade.id;
        isEditing = true;
      }
    } catch (e) {
      // Si hay error al cargar, continuar como nueva calificación
      print('Error al cargar calificación existente: $e');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Editar Calificación' : 'Calificar Entrega'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Estudiante ID: ${submission.studentId}'),
                if (submission.groupId.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Grupo ID: ${submission.groupId}'),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submissionDate)}',
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Contenido:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(submission.content),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Criterios de Calificación:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                // Creatividad
                TextField(
                  controller: creativityController,
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Creatividad (0-100)',
                    hintText: 'Ingrese la calificación de creatividad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Presentación
                TextField(
                  controller: presentationController,
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Presentación (0-100)',
                    hintText: 'Ingrese la calificación de presentación',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Contenido
                TextField(
                  controller: contentController,
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Contenido (0-100)',
                    hintText: 'Ingrese la calificación de contenido',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Retroalimentación:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese comentarios para el estudiante',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Guardando calificación...',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                // Validar que todos los criterios estén completos
                if (creativityController.text.isEmpty ||
                    presentationController.text.isEmpty ||
                    contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor complete todos los criterios de calificación'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Convertir a números y validar rango
                final creativity = double.tryParse(creativityController.text);
                final presentation = double.tryParse(presentationController.text);
                final content = double.tryParse(contentController.text);

                if (creativity == null || creativity < 0 || creativity > 100 ||
                    presentation == null || presentation < 0 || presentation > 100 ||
                    content == null || content < 0 || content > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las calificaciones deben ser números entre 0 y 100'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Activar estado de carga
                setState(() {
                  isLoading = true;
                });

                try {
                  // Crear el objeto de criterios
                  final criterias = {
                    'creatividad': creativity,
                    'presentacion': presentation,
                    'contenido': content,
                  };

                  bool success;
                  String successMessage;

                  if (isEditing && existingGradeId != null) {
                    // Actualizar calificación existente
                    final updatedGrade = Grade(
                      id: existingGradeId,
                      assessmentId: '', // Se puede obtener del contexto si es necesario
                      activityId: submission.activityId,
                      courseId: submission.courseId,
                      groupId: submission.groupId,
                      studentId: submission.studentId,
                      criterias: criterias,
                      finalGrade: (creativity + presentation + content) / 3,
                      feedback: feedbackController.text.isEmpty ? null : feedbackController.text,
                      gradedBy: 'teacher', // Se puede obtener del usuario actual
                      gradedAt: DateTime.now(),
                    );

                    success = await _gradeController.updateGrade(updatedGrade).timeout(
                      const Duration(seconds: 30),
                      onTimeout: () {
                        throw Exception('Tiempo de espera agotado. Verifique su conexión.');
                      },
                    );
                    successMessage = 'Calificación actualizada exitosamente';
                  } else {
                    // Crear nueva calificación
                    success = await _gradeController.createGrade(
                      assessmentId: '', // Se puede obtener del contexto si es necesario
                      activityId: submission.activityId,
                      courseId: submission.courseId,
                      groupId: submission.groupId,
                      studentId: submission.studentId,
                      criterias: criterias,
                      gradedBy: 'teacher', // Se puede obtener del usuario actual
                      feedback: feedbackController.text.isEmpty ? null : feedbackController.text,
                    ).timeout(
                      const Duration(seconds: 30),
                      onTimeout: () {
                        throw Exception('Tiempo de espera agotado. Verifique su conexión.');
                      },
                    );
                    successMessage = 'Calificación guardada exitosamente';
                  }

                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(successMessage),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Recargar las entregas para mostrar la calificación actualizada
                    _loadSubmissions();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar calificación: ${_gradeController.errorMessage.value}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  // Desactivar estado de carga
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Text(isEditing ? 'Actualizar Calificación' : 'Guardar Calificación'),
            ),
          ],
        ),
      ),
    );
  }
}
