import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/group.dart';
import 'dart:math';

class GroupGenerationDialog extends StatefulWidget {
  final Function(List<Group>) onSave;
  final List<String> availableStudentIds;
  final int defaultGroupSize;

  const GroupGenerationDialog({
    super.key,
    required this.onSave,
    this.availableStudentIds = const [],
    required this.defaultGroupSize,
  });

  @override
  State<GroupGenerationDialog> createState() => _GroupGenerationDialogState();
}

class _GroupGenerationDialogState extends State<GroupGenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _numberOfGroups;
  late int _groupSize;
  final TextEditingController _numberOfGroupsController = TextEditingController();
  final TextEditingController _groupSizeController = TextEditingController();
  
  bool _useNumberOfGroups = true; // True for number of groups, false for group size

  @override
  void initState() {
    super.initState();
    _groupSize = widget.defaultGroupSize;
    _numberOfGroups = widget.availableStudentIds.isEmpty 
        ? 1 
        : (widget.availableStudentIds.length / widget.defaultGroupSize).ceil();
    
    _numberOfGroupsController.text = _numberOfGroups.toString();
    _groupSizeController.text = _groupSize.toString();
  }

  @override
  void dispose() {
    _numberOfGroupsController.dispose();
    _groupSizeController.dispose();
    super.dispose();
  }

  int get _calculatedGroupSize {
    if (_useNumberOfGroups) {
      return _numberOfGroups > 0 
          ? (widget.availableStudentIds.length / _numberOfGroups).ceil()
          : widget.defaultGroupSize;
    }
    return _groupSize;
  }

  int get _calculatedNumberOfGroups {
    if (_useNumberOfGroups) {
      return _numberOfGroups;
    }
    return _groupSize > 0 
        ? (widget.availableStudentIds.length / _groupSize).ceil()
        : 1;
  }

  List<Group> _generateRandomGroups() {
    final random = Random();
    final shuffledStudents = List<String>.from(widget.availableStudentIds)
      ..shuffle(random);
    
    final List<Group> groups = [];
    final int actualNumberOfGroups = _calculatedNumberOfGroups;
    final int actualGroupSize = _calculatedGroupSize;
    
    for (int i = 0; i < actualNumberOfGroups; i++) {
      final int start = i * actualGroupSize;
      final int end = (start + actualGroupSize < shuffledStudents.length) 
          ? start + actualGroupSize 
          : shuffledStudents.length;
      
      if (start < shuffledStudents.length) {
        final groupStudents = shuffledStudents.sublist(start, end);
        groups.add(Group(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
          name: 'Grupo ${i + 1}',
          studentIds: groupStudents,
          createdAt: DateTime.now(),
        ));
      }
    }
    
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int totalStudents = widget.availableStudentIds.length;
    
    return AlertDialog(
      title: const Text('Generar Grupos Aleatoriamente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total de estudiantes disponibles: $totalStudents',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              // Toggle between number of groups and group size
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Número de grupos'),
                      value: true,
                      groupValue: _useNumberOfGroups,
                      onChanged: (value) {
                        setState(() {
                          _useNumberOfGroups = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Tamaño del grupo'),
                      value: false,
                      groupValue: _useNumberOfGroups,
                      onChanged: (value) {
                        setState(() {
                          _useNumberOfGroups = !value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (_useNumberOfGroups) ...[
                TextFormField(
                  controller: _numberOfGroupsController,
                  decoration: const InputDecoration(
                    labelText: 'Número de grupos',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.groups),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el número de grupos';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1) {
                      return 'Debe ser un número positivo';
                    }
                    if (number > totalStudents) {
                      return 'No puede ser mayor al número de estudiantes';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final number = int.tryParse(value);
                    if (number != null && number > 0) {
                      setState(() {
                        _numberOfGroups = number;
                      });
                    }
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _groupSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Tamaño del grupo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el tamaño del grupo';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 2) {
                      return 'El tamaño mínimo es 2';
                    }
                    if (number > totalStudents) {
                      return 'No puede ser mayor al número de estudiantes';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final number = int.tryParse(value);
                    if (number != null && number >= 2) {
                      setState(() {
                        _groupSize = number;
                      });
                    }
                  },
                ),
              ],
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vista previa:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Se crearán ${_calculatedNumberOfGroups} grupos'),
                    Text('Tamaño aproximado: ${_calculatedGroupSize} estudiantes por grupo'),
                    if (_calculatedNumberOfGroups * _calculatedGroupSize != totalStudents)
                      Text(
                        'Nota: Algunos grupos pueden tener un estudiante menos',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (totalStudents == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No hay estudiantes disponibles para crear grupos'),
                  ),
                );
                return;
              }
              
              final groups = _generateRandomGroups();
              widget.onSave(groups);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Generar Grupos'),
        ),
      ],
    );
  }
}