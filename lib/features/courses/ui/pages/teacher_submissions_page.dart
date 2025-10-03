import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/models/activity.dart';
import '../../domain/models/submission.dart';
import '../controllers/submission_controller.dart';

class TeacherSubmissionsPage extends StatefulWidget {
  final Activity activity;

  const TeacherSubmissionsPage({Key? key, required this.activity})
    : super(key: key);

  @override
  State<TeacherSubmissionsPage> createState() => _TeacherSubmissionsPageState();
}

class _TeacherSubmissionsPageState extends State<TeacherSubmissionsPage> {
  final SubmissionController _controller = Get.find<SubmissionController>();

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

  void _showSubmissionDetails(Submission submission) {
    final TextEditingController gradeController = TextEditingController(
      text: submission.grade ?? '',
    );
    final TextEditingController feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la entrega'),
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
                'Calificación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(
                  hintText: 'Ingrese la calificación',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Retroalimentación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ingrese comentarios para el estudiante',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedSubmission = Submission(
                id: submission.id,
                studentId: submission.studentId,
                activityId: submission.activityId,
                groupId: submission.groupId,
                content: submission.content,
                submissionDate: submission.submissionDate,
                grade: gradeController.text,
                feedback: feedbackController.text,
                courseId: submission.courseId,
              );

              final success = await _controller.updateSubmission(
                updatedSubmission,
              );
              if (success) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
