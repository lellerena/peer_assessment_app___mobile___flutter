import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/category.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const AddEditCategoryDialog({super.key, this.category, required this.onSave});

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late GroupingMethod _groupingMethod;
  late double _groupSize;
  late String _id;
  late TextEditingController _sizeController;

  @override
  void initState() {
    super.initState();
    _id = widget.category?.id ?? DateTime.now().toIso8601String();
    _name = widget.category?.name ?? '';
    _groupingMethod = widget.category?.groupingMethod ?? GroupingMethod.random;
    // Set default group size to 2 for new categories, otherwise use existing
    _groupSize = (widget.category?.groupSize ?? 2).toDouble();
    _sizeController = TextEditingController(
      text: _groupSize.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.category == null ? 'Agregar Categoría' : 'Editar Categoría'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<GroupingMethod>(
                value: _groupingMethod,
                decoration: const InputDecoration(
                  labelText: 'Método de Agrupación',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group_work),
                ),
                items: GroupingMethod.values
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(_getGroupingMethodText(method)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _groupingMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Tamaño del Grupo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un tamaño';
                  }
                  final size = int.tryParse(value);
                  if (size == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  if (size < 2) {
                    return 'El tamaño del grupo debe ser al menos 2';
                  }
                  return null;
                },
                onChanged: (value) {
                  final size = double.tryParse(value);
                  if (size != null && size >= 2 && size <= 50) {
                    setState(() {
                      _groupSize = size;
                    });
                  }
                },
                onSaved: (value) => _groupSize = double.parse(value!),
              ),
              Slider(
                value: _groupSize,
                min: 2,
                max: 50,
                divisions: 48,
                label: _groupSize.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _groupSize = value;
                    _sizeController.text = value.round().toString();
                  });
                },
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
              _formKey.currentState!.save();
              final newCategory = Category(
                id: _id,
                name: _name,
                groupingMethod: _groupingMethod,
                groupSize: _groupSize.toInt(),
                courseId: '', // Este será asignado por el controlador
              );
              widget.onSave(newCategory);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  String _getGroupingMethodText(GroupingMethod method) {
    switch (method) {
      case GroupingMethod.random:
        return 'Aleatorio';
      case GroupingMethod.selfAssigned:
        return 'Auto-asignado';
      case GroupingMethod.manual:
        return 'Manual';
    }
  }
}
