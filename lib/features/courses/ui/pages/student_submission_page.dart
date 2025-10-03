import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/models/activity.dart';
import '../../domain/models/group.dart';
import '../../domain/models/submission.dart';
import '../controllers/submission_controller.dart';

class StudentSubmissionPage extends StatefulWidget {
  final Activity activity;
  final Group? group;
  final String studentId;

  const StudentSubmissionPage({
    Key? key,
    required this.activity,
    required this.studentId,
    this.group,
  }) : super(key: key);

  @override
  State<StudentSubmissionPage> createState() => _StudentSubmissionPageState();
}

class _StudentSubmissionPageState extends State<StudentSubmissionPage> {
  final SubmissionController _controller = Get.find<SubmissionController>();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasExistingSubmission = false;
  Submission? _existingSubmission;

  @override
  void initState() {
    super.initState();
    _checkExistingSubmission();
  }

  Future<void> _checkExistingSubmission() async {
    // Comprueba si el estudiante ya ha realizado una entrega para esta actividad
    try {
      await _controller.getSubmissionsByActivityId(widget.activity.id);

      final submissions = _controller.submissions;
      final studentSubmission = submissions.firstWhere(
        (s) =>
            s.studentId == widget.studentId &&
            s.activityId == widget.activity.id,
        orElse: () => Submission(
          id: '',
          studentId: '',
          activityId: '',
          groupId: '',
          content: '',
          submissionDate: DateTime.now(),
          courseId: '',
        ),
      );

      if (studentSubmission.id.isNotEmpty) {
        setState(() {
          _hasExistingSubmission = true;
          _existingSubmission = studentSubmission;
          _contentController.text = studentSubmission.content;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo verificar entregas existentes');
    }
  }

  Future<void> _loadExistingSubmission() async {
    // Carga la entrega recién creada para obtener su ID real
    try {
      await _controller.getSubmissionsByActivityId(widget.activity.id);

      final submissions = _controller.submissions;
      final studentSubmission = submissions.firstWhere(
        (s) =>
            s.studentId == widget.studentId &&
            s.activityId == widget.activity.id,
        orElse: () => Submission(
          id: '',
          studentId: '',
          activityId: '',
          groupId: '',
          content: '',
          submissionDate: DateTime.now(),
          courseId: '',
        ),
      );

      if (studentSubmission.id.isNotEmpty) {
        setState(() {
          _hasExistingSubmission = true;
          _existingSubmission = studentSubmission;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar la entrega creada');
    }
  }

  Future<void> _submitWork() async {
    if (_contentController.text.trim().isEmpty) {
      Get.snackbar('Error', 'El contenido de la entrega no puede estar vacío');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final now = DateTime.now();

    try {
      bool success;

      if (_hasExistingSubmission && _existingSubmission != null) {
        // Actualiza una entrega existente
        final updatedSubmission = Submission(
          id: _existingSubmission!.id,
          studentId: widget.studentId,
          activityId: widget.activity.id,
          groupId: widget.group?.id ?? '',
          content: _contentController.text,
          submissionDate: now,
          grade: _existingSubmission!.grade,
          feedback: _existingSubmission!.feedback,
          courseId: widget.activity.courseId,
        );

        success = await _controller.updateSubmission(updatedSubmission);
      } else {
        // Crea una nueva entrega
        final newSubmission = Submission(
          // Dejamos que la API genere el ID
          id: '',
          studentId: widget.studentId,
          activityId: widget.activity.id,
          groupId: widget.group?.id ?? '',
          content: _contentController.text,
          submissionDate: now,
          courseId: widget.activity.courseId,
        );

        success = await _controller.addSubmission(newSubmission);
        if (success) {
          // Obtenemos la entrega recién creada para obtener su ID real
          await _loadExistingSubmission();
        }
      }

      if (success) {
        Get.back();
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entrega: ${widget.activity.title}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.activity.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy').format(widget.activity.date)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    if (widget.group != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.group),
                          const SizedBox(width: 8),
                          Text(
                            'Grupo: ${widget.group!.name}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tu entrega:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_hasExistingSubmission && _existingSubmission != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Última entrega: ${DateFormat('dd/MM/yyyy HH:mm').format(_existingSubmission!.submissionDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            TextField(
              controller: _contentController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Escribe tu entrega aquí...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (_hasExistingSubmission &&
                _existingSubmission != null &&
                _existingSubmission!.grade != null) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calificación:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _existingSubmission!.grade ?? 'No calificado',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_existingSubmission!.feedback != null &&
                          _existingSubmission!.feedback!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Retroalimentación:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _existingSubmission!.feedback ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitWork,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(
                        _hasExistingSubmission
                            ? 'Actualizar entrega'
                            : 'Enviar entrega',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
