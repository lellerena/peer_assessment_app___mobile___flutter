import 'package:flutter/material.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/activity.dart';

class AddEditAssessmentDialog extends StatefulWidget {
  final Assessment? assessment;
  final String courseId;
  final List<Activity> activities;
  final Function(Assessment) onSave;

  const AddEditAssessmentDialog({
    Key? key,
    this.assessment,
    required this.courseId,
    required this.activities,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditAssessmentDialog> createState() => _AddEditAssessmentDialogState();
}

class _AddEditAssessmentDialogState extends State<AddEditAssessmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedActivityId;
  AssessmentVisibility _visibility = AssessmentVisibility.private;
  int _durationValue = 60;
  String _durationUnit = 'minutes';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

      void _initializeForm() {
        if (widget.assessment != null) {
          _nameController.text = widget.assessment!.name;
          _selectedActivityId = widget.assessment!.activityId; // Usar activityId correctamente
          _visibility = widget.assessment!.visibility;
          // Usar los nuevos campos de duración
          _durationValue = widget.assessment!.durationValue;
          _durationUnit = widget.assessment!.durationUnit;
        }
      }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.assessment == null ? 'Crear Evaluación' : 'Editar Evaluación',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nombre de la evaluación
                _buildSectionTitle('Nombre'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Evaluación Final',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selección de Actividad
                _buildSectionTitle('Actividad'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedActivityId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment_turned_in, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  hint: const Text('Selecciona una actividad'),
                  items: widget.activities.map((activity) {
                    return DropdownMenuItem<String>(
                      value: activity.id,
                      child: Text(
                        activity.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debes seleccionar una actividad';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ventana de tiempo
                _buildSectionTitle('Duración'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: _durationValue.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer, size: 20),
                          hintText: '60',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (value) {
                          _durationValue = int.tryParse(value) ?? 60;
                        },
                        validator: (value) {
                          final duration = int.tryParse(value ?? '');
                          if (duration == null || duration <= 0) {
                            return 'Duración inválida';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _durationUnit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'minutes', child: Text('Min')),
                          DropdownMenuItem(value: 'hours', child: Text('Hrs')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _durationUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Visibilidad
                _buildSectionTitle('Visibilidad'),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<AssessmentVisibility>(
                        title: const Text('Pública', style: TextStyle(fontSize: 14)),
                        subtitle: const Text('Resultados visibles para el grupo', style: TextStyle(fontSize: 12)),
                        value: AssessmentVisibility.public,
                        groupValue: _visibility,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        onChanged: (value) {
                          setState(() {
                            _visibility = value!;
                          });
                        },
                      ),
                      RadioListTile<AssessmentVisibility>(
                        title: const Text('Privada', style: TextStyle(fontSize: 14)),
                        subtitle: const Text('Solo visible para el profesor', style: TextStyle(fontSize: 12)),
                        value: AssessmentVisibility.private,
                        groupValue: _visibility,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        onChanged: (value) {
                          setState(() {
                            _visibility = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveAssessment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(widget.assessment == null ? 'Crear' : 'Actualizar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  void _saveAssessment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedActivityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una actividad'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calcular fechas basadas en la duración
    final now = DateTime.now();
    final duration = _durationUnit == 'hours' 
        ? Duration(hours: _durationValue)
        : Duration(minutes: _durationValue);
    final endDate = now.add(duration);

        final assessment = Assessment(
          id: widget.assessment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          description: 'Evaluación de pares para ${widget.activities.firstWhere((a) => a.id == _selectedActivityId).title}',
          courseId: widget.courseId,
          activityId: _selectedActivityId!, // Usar activityId correctamente
          status: AssessmentStatus.draft,
          visibility: _visibility,
          durationValue: _durationValue, // Nuevo campo
          durationUnit: _durationUnit, // Nuevo campo
          startDate: now,
          endDate: endDate,
          criteria: [
            AssessmentCriteria(
              id: 'creatividad',
              name: 'Creatividad',
              description: 'Evaluación de la creatividad en el trabajo',
              scaleType: ScaleType.numeric,
              isRequired: true,
              scaleConfig: {'min': 0, 'max': 100},
            ),
            AssessmentCriteria(
              id: 'contenido',
              name: 'Contenido',
              description: 'Evaluación del contenido y calidad del trabajo',
              scaleType: ScaleType.numeric,
              isRequired: true,
              scaleConfig: {'min': 0, 'max': 100},
            ),
            AssessmentCriteria(
              id: 'presentacion',
              name: 'Presentación',
              description: 'Evaluación de la presentación y claridad',
              scaleType: ScaleType.numeric,
              isRequired: true,
              scaleConfig: {'min': 0, 'max': 100},
            ),
          ],
          createdAt: widget.assessment?.createdAt ?? now,
          updatedAt: now,
        );

    widget.onSave(assessment);
    Navigator.of(context).pop();
  }
}
