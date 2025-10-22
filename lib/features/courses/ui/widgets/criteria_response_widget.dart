import 'package:flutter/material.dart';
import '../../domain/models/assessment.dart';

class CriteriaResponseWidget extends StatefulWidget {
  final AssessmentCriteria criteria;
  final dynamic initialValue;
  final Function(dynamic) onChanged;

  const CriteriaResponseWidget({
    Key? key,
    required this.criteria,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CriteriaResponseWidget> createState() => _CriteriaResponseWidgetState();
}

class _CriteriaResponseWidgetState extends State<CriteriaResponseWidget> {
  dynamic _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.criteria.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (widget.criteria.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.criteria.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.criteria.isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Requerido',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResponseWidget(),
        ],
      ),
    );
  }

  Widget _buildResponseWidget() {
    switch (widget.criteria.scaleType) {
      case ScaleType.stars:
        return _buildStarsWidget();
      case ScaleType.numeric:
        return _buildNumericWidget();
      case ScaleType.binary:
        return _buildBinaryWidget();
      case ScaleType.comment:
        return _buildCommentWidget();
    }
  }

  Widget _buildStarsWidget() {
    final minValue = widget.criteria.scaleConfig?['min'] ?? 2.0;
    final maxValue = widget.criteria.scaleConfig?['max'] ?? 5.0;
    final labels = widget.criteria.scaleConfig?['labels'] as List<String>?;
    
    // Para escala 2.0-5.0, tenemos 4 niveles (2.0, 3.0, 4.0, 5.0)
    final levels = [2.0, 3.0, 4.0, 5.0];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(levels.length, (index) {
            final levelValue = levels[index];
            final isSelected = _currentValue != null && _currentValue == levelValue;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentValue = levelValue;
                });
                widget.onChanged(_currentValue);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.amber[700]! : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      levelValue.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (labels != null && labels.length >= levels.length) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _currentValue != null 
                  ? labels[levels.indexOf(_currentValue)]
                  : 'Selecciona una calificación',
              style: TextStyle(
                fontSize: 14,
                color: _currentValue != null ? Colors.black87 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNumericWidget() {
    final min = widget.criteria.scaleConfig?['min'] ?? 0;
    final max = widget.criteria.scaleConfig?['max'] ?? 100;
    final step = widget.criteria.scaleConfig?['step'] ?? 1;
    
    return Column(
      children: [
        Row(
          children: [
            Text('$min'),
            Expanded(
              child: Slider(
                value: (_currentValue ?? min).toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: ((max - min) / step).round(),
                onChanged: (value) {
                  setState(() {
                    _currentValue = (value / step).round() * step;
                  });
                  widget.onChanged(_currentValue);
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            Text('$max'),
          ],
        ),
        Text(
          'Valor: ${_currentValue ?? min}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBinaryWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBinaryOption('Sí', true, Icons.check_circle),
        const SizedBox(width: 32),
        _buildBinaryOption('No', false, Icons.cancel),
      ],
    );
  }

  Widget _buildBinaryOption(String label, bool value, IconData icon) {
    final isSelected = _currentValue == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentValue = value;
        });
        widget.onChanged(_currentValue);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentWidget() {
    return TextFormField(
      initialValue: _currentValue?.toString() ?? '',
      decoration: const InputDecoration(
        hintText: 'Escribe tu comentario aquí...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          _currentValue = value.isEmpty ? null : value;
        });
        widget.onChanged(_currentValue);
      },
    );
  }
}
