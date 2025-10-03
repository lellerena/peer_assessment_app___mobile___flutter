import 'package:flutter/material.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/category.dart';

class AddEditAssessmentDialog extends StatefulWidget {
  final Assessment? assessment;
  final String courseId;
  final List<Category> categories;
  final Function(Assessment) onSave;

  const AddEditAssessmentDialog({
    Key? key,
    this.assessment,
    required this.courseId,
    required this.categories,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditAssessmentDialog> createState() => _AddEditAssessmentDialogState();
}

class _AddEditAssessmentDialogState extends State<AddEditAssessmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategoryId;
  AssessmentVisibility _visibility = AssessmentVisibility.private;
  DateTime? _startDate;
  DateTime? _endDate;
  
  final List<AssessmentCriteria> _criteria = [];
  final List<TextEditingController> _criteriaNameControllers = [];
  final List<TextEditingController> _criteriaDescriptionControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.assessment != null) {
      _nameController.text = widget.assessment!.name;
      _descriptionController.text = widget.assessment!.description;
      _selectedCategoryId = widget.assessment!.categoryId;
      _visibility = widget.assessment!.visibility;
      _startDate = widget.assessment!.startDate;
      _endDate = widget.assessment!.endDate;
      
      _criteria.addAll(widget.assessment!.criteria);
      for (final criteria in _criteria) {
        _criteriaNameControllers.add(TextEditingController(text: criteria.name));
        _criteriaDescriptionControllers.add(TextEditingController(text: criteria.description));
      }
    } else {
      // Agregar criterios por defecto
      _addDefaultCriteria();
    }
  }

  void _addDefaultCriteria() {
    final defaultCriteria = [
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_1',
        name: 'Puntualidad',
        description: 'Cumplimiento de tiempos y fechas límite',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {'min': 1, 'max': 5, 'labels': ['Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente']},
      ),
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_2',
        name: 'Contribuciones',
        description: 'Calidad y cantidad de aportes al trabajo en equipo',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {'min': 1, 'max': 5, 'labels': ['Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente']},
      ),
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_3',
        name: 'Compromiso',
        description: 'Dedicación y responsabilidad en las tareas asignadas',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {'min': 1, 'max': 5, 'labels': ['Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente']},
      ),
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_4',
        name: 'Actitud',
        description: 'Disposición y colaboración con el equipo',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {'min': 1, 'max': 5, 'labels': ['Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente']},
      ),
    ];

    _criteria.addAll(defaultCriteria);
    for (final criteria in _criteria) {
      _criteriaNameControllers.add(TextEditingController(text: criteria.name));
      _criteriaDescriptionControllers.add(TextEditingController(text: criteria.description));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final controller in _criteriaNameControllers) {
      controller.dispose();
    }
    for (final controller in _criteriaDescriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.assessment == null ? 'Crear Evaluación' : 'Editar Evaluación',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información básica
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la evaluación',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Selección de categoría
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecciona una categoría';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Visibilidad
                      DropdownButtonFormField<AssessmentVisibility>(
                        value: _visibility,
                        decoration: const InputDecoration(
                          labelText: 'Visibilidad',
                          border: OutlineInputBorder(),
                        ),
                        items: AssessmentVisibility.values.map((visibility) {
                          return DropdownMenuItem<AssessmentVisibility>(
                            value: visibility,
                            child: Text(visibility == AssessmentVisibility.public ? 'Público' : 'Privado'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _visibility = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Fechas
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectStartDate(),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de inicio',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _startDate != null 
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} ${_startDate!.hour}:${_startDate!.minute.toString().padLeft(2, '0')}'
                                      : 'Seleccionar fecha',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectEndDate(),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de fin',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _endDate != null 
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year} ${_endDate!.hour}:${_endDate!.minute.toString().padLeft(2, '0')}'
                                      : 'Seleccionar fecha',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Criterios
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Criterios de Evaluación',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addCriteria,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar'),
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
                      const SizedBox(height: 16),
                      ...List.generate(_criteria.length, (index) {
                        return _buildCriteriaCard(index);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveAssessment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(widget.assessment == null ? 'Crear' : 'Actualizar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriteriaCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _criteriaNameControllers[index],
                  decoration: const InputDecoration(
                    labelText: 'Nombre del criterio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => _removeCriteria(index),
                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                tooltip: 'Eliminar criterio',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _criteriaDescriptionControllers[index],
            decoration: const InputDecoration(
              labelText: 'Descripción del criterio',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La descripción es requerida';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ScaleType>(
                  value: _criteria[index].scaleType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de escala',
                    border: OutlineInputBorder(),
                  ),
                  items: ScaleType.values.map((type) {
                    String label;
                    switch (type) {
                      case ScaleType.stars:
                        label = 'Estrellas (1-5)';
                        break;
                      case ScaleType.numeric:
                        label = 'Numérico (0-100)';
                        break;
                      case ScaleType.binary:
                        label = 'Sí/No';
                        break;
                      case ScaleType.comment:
                        label = 'Comentario';
                        break;
                    }
                    return DropdownMenuItem<ScaleType>(
                      value: type,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _criteria[index] = AssessmentCriteria(
                        id: _criteria[index].id,
                        name: _criteria[index].name,
                        description: _criteria[index].description,
                        scaleType: value!,
                        isRequired: _criteria[index].isRequired,
                        scaleConfig: _criteria[index].scaleConfig,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: _criteria[index].isRequired,
                onChanged: (value) {
                  setState(() {
                    _criteria[index] = AssessmentCriteria(
                      id: _criteria[index].id,
                      name: _criteria[index].name,
                      description: _criteria[index].description,
                      scaleType: _criteria[index].scaleType,
                      isRequired: value,
                      scaleConfig: _criteria[index].scaleConfig,
                    );
                  });
                },
              ),
              const Text('Requerido'),
            ],
          ),
        ],
      ),
    );
  }

  void _addCriteria() {
    setState(() {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _criteria.add(AssessmentCriteria(
        id: newId,
        name: '',
        description: '',
        scaleType: ScaleType.stars,
        isRequired: true,
      ));
      _criteriaNameControllers.add(TextEditingController());
      _criteriaDescriptionControllers.add(TextEditingController());
    });
  }

  void _removeCriteria(int index) {
    setState(() {
      _criteria.removeAt(index);
      _criteriaNameControllers[index].dispose();
      _criteriaDescriptionControllers.removeAt(index);
    });
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _startDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDate ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _endDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveAssessment() {
    if (_formKey.currentState!.validate()) {
      // Actualizar criterios con los valores de los controladores
      final updatedCriteria = <AssessmentCriteria>[];
      for (int i = 0; i < _criteria.length; i++) {
        updatedCriteria.add(AssessmentCriteria(
          id: _criteria[i].id,
          name: _criteriaNameControllers[i].text,
          description: _criteriaDescriptionControllers[i].text,
          scaleType: _criteria[i].scaleType,
          isRequired: _criteria[i].isRequired,
          scaleConfig: _criteria[i].scaleConfig,
        ));
      }

      final assessment = Assessment(
        id: widget.assessment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        courseId: widget.courseId,
        categoryId: _selectedCategoryId!,
        status: widget.assessment?.status ?? AssessmentStatus.draft,
        visibility: _visibility,
        startDate: _startDate,
        endDate: _endDate,
        criteria: updatedCriteria,
        createdAt: widget.assessment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(assessment);
      Navigator.of(context).pop();
    }
  }
}
