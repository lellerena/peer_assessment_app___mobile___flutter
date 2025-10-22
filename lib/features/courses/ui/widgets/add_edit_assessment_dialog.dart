import 'package:flutter/material.dart';
import '../../domain/models/assessment.dart';
import '../../domain/models/category.dart';
import '../../domain/models/activity.dart'; // NUEVO: Importar Activity

class AddEditAssessmentDialog extends StatefulWidget {
  final Assessment? assessment;
  final String courseId;
  final List<Category> categories;
  final List<Activity> activities; // NUEVO: Lista de actividades
  final Function(Assessment) onSave;

  const AddEditAssessmentDialog({
    Key? key,
    this.assessment,
    required this.courseId,
    required this.categories,
    required this.activities, // NUEVO: Requerido
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
  String? _selectedActivityId; // NUEVO: Actividad seleccionada
  AssessmentVisibility _visibility = AssessmentVisibility.private;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // NUEVO: Criterios como opción adicional
  bool _showCriteriaSection = false;
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
      _selectedActivityId = widget.assessment!.activityId; // NUEVO: Inicializar actividad
      _visibility = widget.assessment!.visibility;
      _startDate = widget.assessment!.startDate;
      _endDate = widget.assessment!.endDate;
      
      // Si hay criterios existentes, mostrar la sección
      if (widget.assessment!.criteria.isNotEmpty) {
        _showCriteriaSection = true;
        _criteria.addAll(widget.assessment!.criteria);
        for (final criteria in _criteria) {
          _criteriaNameControllers.add(TextEditingController(text: criteria.name));
          _criteriaDescriptionControllers.add(TextEditingController(text: criteria.description));
        }
      }
    }
    // NUEVO: No agregar criterios por defecto automáticamente
  }

  // NUEVO: Obtener actividades filtradas por categoría seleccionada
  List<Activity> _getActivitiesForSelectedCategory() {
    if (_selectedCategoryId == null) return [];
    return widget.activities.where((activity) => activity.categoryId == _selectedCategoryId).toList();
  }

  void _addDefaultCriteria() {
    final defaultCriteria = [
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_1',
        name: 'Puntualidad',
        description: 'El estudiante llegó tarde o estuvo ausente con frecuencia, afectando el trabajo del grupo.',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {
          'min': 2.0, 
          'max': 5.0, 
          'labels': [
            'Needs Improvement (2.0)',
            'Adequate (3.0)', 
            'Good (4.0)', 
            'Excellent (5.0)'
          ]
        },
      ),
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_2',
        name: 'Contribuciones',
        description: 'No participó o fue pasivo durante las actividades del equipo.',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {
          'min': 2.0, 
          'max': 5.0, 
          'labels': [
            'Needs Improvement (2.0)',
            'Adequate (3.0)', 
            'Good (4.0)', 
            'Excellent (5.0)'
          ]
        },
      ),
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_3',
        name: 'Compromiso',
        description: 'Mostró poco compromiso con las tareas asignadas.',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {
          'min': 2.0, 
          'max': 5.0, 
          'labels': [
            'Needs Improvement (2.0)',
            'Adequate (3.0)', 
            'Good (4.0)', 
            'Excellent (5.0)'
          ]
        },
      ),
      AssessmentCriteria(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_4',
        name: 'Actitud',
        description: 'Tuvo una actitud negativa o indiferente hacia las actividades del equipo.',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {
          'min': 2.0, 
          'max': 5.0, 
          'labels': [
            'Needs Improvement (2.0)',
            'Adequate (3.0)', 
            'Good (4.0)', 
            'Excellent (5.0)'
          ]
        },
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
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header mejorado
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
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información básica
                      _buildSectionCard(
                        title: 'Información Básica',
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la evaluación',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.assignment),
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
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La descripción es requerida';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Selección de categoría y actividad
                      _buildSectionCard(
                        title: 'Configuración',
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
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
                                _selectedActivityId = null; // Reset actividad al cambiar categoría
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
                          DropdownButtonFormField<String>(
                            value: _selectedActivityId,
                            decoration: const InputDecoration(
                              labelText: 'Actividad',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.work),
                            ),
                            items: _getActivitiesForSelectedCategory().map((activity) {
                              return DropdownMenuItem<String>(
                                value: activity.id,
                                child: Text(activity.title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedActivityId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecciona una actividad';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Configuración de visibilidad y fechas
                      _buildSectionCard(
                        title: 'Configuración Avanzada',
                        children: [
                          DropdownButtonFormField<AssessmentVisibility>(
                            value: _visibility,
                            decoration: const InputDecoration(
                              labelText: 'Visibilidad',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.visibility),
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
                          // Fechas en columnas para móvil
                          Column(
                            children: [
                              InkWell(
                                onTap: () => _selectStartDate(),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha de inicio',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.schedule),
                                  ),
                                  child: Text(
                                    _startDate != null 
                                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} ${_startDate!.hour}:${_startDate!.minute.toString().padLeft(2, '0')}'
                                        : 'Seleccionar fecha',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => _selectEndDate(),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha de fin',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.schedule),
                                  ),
                                  child: Text(
                                    _endDate != null 
                                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year} ${_endDate!.hour}:${_endDate!.minute.toString().padLeft(2, '0')}'
                                        : 'Seleccionar fecha',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // NUEVO: Criterios como opción adicional
                      _buildCriteriaSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botones de acción mejorados para móvil
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.assessment == null ? 'Crear Evaluación' : 'Actualizar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NUEVO: Método para construir secciones con tarjetas
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // NUEVO: Método para construir la sección de criterios como opcional
  Widget _buildCriteriaSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header con toggle
          InkWell(
            onTap: () {
              setState(() {
                _showCriteriaSection = !_showCriteriaSection;
                if (_showCriteriaSection && _criteria.isEmpty) {
                  _addDefaultCriteria();
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _showCriteriaSection ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Criterios de Evaluación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _showCriteriaSection ? 'Ocultar' : 'Mostrar',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Contenido expandible
          if (_showCriteriaSection) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Botón para agregar criterio
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addCriteria,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar Criterio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Lista de criterios
                  ...List.generate(_criteria.length, (index) {
                    return _buildCriteriaCard(index);
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCriteriaCard(int index) {
    // Verificar que el índice sea válido
    if (index < 0 || index >= _criteria.length || 
        index >= _criteriaNameControllers.length || 
        index >= _criteriaDescriptionControllers.length) {
      return const SizedBox.shrink();
    }
    
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
                flex: 4,
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
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeCriteria(index),
                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                tooltip: 'Eliminar criterio',
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
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
          DropdownButtonFormField<ScaleType>(
            value: _criteria[index].scaleType,
            decoration: const InputDecoration(
              labelText: 'Tipo de escala',
              border: OutlineInputBorder(),
            ),
            items: ScaleType.values.map((type) {
              String label;
              switch (type) {
                case ScaleType.stars:
                  label = 'Estrellas (2.0-5.0)';
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
        ],
      ),
    );
  }

  void _addCriteria() {
    setState(() {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Crear el nuevo criterio con configuración por defecto
      final newCriteria = AssessmentCriteria(
        id: newId,
        name: '',
        description: '',
        scaleType: ScaleType.stars,
        isRequired: true,
        scaleConfig: {
          'min': 2.0,
          'max': 5.0,
          'labels': [
            'Needs Improvement (2.0)',
            'Adequate (3.0)',
            'Good (4.0)',
            'Excellent (5.0)'
          ]
        },
      );
      
      // Agregar a la lista de criterios
      _criteria.add(newCriteria);
      
      // Crear y agregar los controladores correspondientes
      _criteriaNameControllers.add(TextEditingController());
      _criteriaDescriptionControllers.add(TextEditingController());
      
      // Verificar que las listas estén sincronizadas
      assert(_criteria.length == _criteriaNameControllers.length);
      assert(_criteria.length == _criteriaDescriptionControllers.length);
    });
  }

  void _removeCriteria(int index) {
    // Verificar que el índice sea válido
    if (index < 0 || index >= _criteria.length) return;
    
    setState(() {
      // Dispose de los controladores antes de eliminarlos
      if (index < _criteriaNameControllers.length) {
        _criteriaNameControllers[index].dispose();
      }
      if (index < _criteriaDescriptionControllers.length) {
        _criteriaDescriptionControllers[index].dispose();
      }
      
      // Eliminar de las listas
      _criteria.removeAt(index);
      if (index < _criteriaNameControllers.length) {
        _criteriaNameControllers.removeAt(index);
      }
      if (index < _criteriaDescriptionControllers.length) {
        _criteriaDescriptionControllers.removeAt(index);
      }
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
      // Actualizar criterios con los valores de los controladores (solo si hay criterios)
      final updatedCriteria = <AssessmentCriteria>[];
      if (_showCriteriaSection && _criteria.isNotEmpty) {
        for (int i = 0; i < _criteria.length; i++) {
          if (i < _criteriaNameControllers.length && i < _criteriaDescriptionControllers.length) {
            updatedCriteria.add(AssessmentCriteria(
              id: _criteria[i].id,
              name: _criteriaNameControllers[i].text,
              description: _criteriaDescriptionControllers[i].text,
              scaleType: _criteria[i].scaleType,
              isRequired: _criteria[i].isRequired,
              scaleConfig: _criteria[i].scaleConfig,
            ));
          }
        }
      }

      final assessment = Assessment(
        id: widget.assessment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        courseId: widget.courseId,
        categoryId: _selectedCategoryId!,
        activityId: _selectedActivityId!, // NUEVO: Incluir activityId
        status: widget.assessment?.status ?? AssessmentStatus.draft,
        visibility: _visibility,
        startDate: _startDate,
        endDate: _endDate,
        criteria: updatedCriteria, // Puede estar vacío si no se configuraron criterios
        createdAt: widget.assessment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave(assessment);
      Navigator.of(context).pop();
    }
  }
}
