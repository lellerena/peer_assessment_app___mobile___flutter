import 'package:flutter/material.dart';
import '../../domain/models/group.dart';

class AddEditGroupDialog extends StatefulWidget {
  final Group? group;
  final Function(Group) onSave;
  final List<String> availableStudentIds;
  final List<String> currentlyAssignedStudentIds;

  const AddEditGroupDialog({
    super.key,
    this.group,
    required this.onSave,
    this.availableStudentIds = const [],
    this.currentlyAssignedStudentIds = const [],
  });

  @override
  State<AddEditGroupDialog> createState() => _AddEditGroupDialogState();
}

class _AddEditGroupDialogState extends State<AddEditGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late List<String> _selectedStudentIds;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = widget.group?.name ?? '';
    _nameController.text = _name;
    _selectedStudentIds = List<String>.from(widget.group?.studentIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<String> get _unassignedStudentIds {
    return widget.availableStudentIds
        .where((id) => !widget.currentlyAssignedStudentIds.contains(id) || 
                      _selectedStudentIds.contains(id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.group == null ? 'Crear Grupo' : 'Editar Grupo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Grupo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del grupo es requerido';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
                onChanged: (value) => _name = value.trim(),
              ),
              const SizedBox(height: 16),
              if (_unassignedStudentIds.isNotEmpty) ...[
                const Text(
                  'Estudiantes Disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _unassignedStudentIds.length,
                    itemBuilder: (context, index) {
                      final studentId = _unassignedStudentIds[index];
                      final isSelected = _selectedStudentIds.contains(studentId);
                      
                      return CheckboxListTile(
                        title: Text('Estudiante $studentId'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedStudentIds.add(studentId);
                            } else {
                              _selectedStudentIds.remove(studentId);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ] else ...[
                const Text(
                  'No hay estudiantes disponibles para asignar',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Estudiantes seleccionados: ${_selectedStudentIds.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
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
              final newGroup = Group(
                id: widget.group?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: _name,
                studentIds: _selectedStudentIds,
                createdAt: widget.group?.createdAt ?? DateTime.now(),
              );
              widget.onSave(newGroup);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}