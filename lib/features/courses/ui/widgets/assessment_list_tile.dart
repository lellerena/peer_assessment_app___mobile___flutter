import 'package:flutter/material.dart';
import '../../domain/models/assessment.dart';

class AssessmentListTile extends StatelessWidget {
  final Assessment assessment;
  final String? categoryName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;
  final VoidCallback? onViewResults;
  final VoidCallback? onStartEvaluation;
  final bool isTeacher;
  final bool canEvaluate;

  const AssessmentListTile({
    Key? key,
    required this.assessment,
    this.categoryName,
    this.onEdit,
    this.onDelete,
    this.onActivate,
    this.onDeactivate,
    this.onViewResults,
    this.onStartEvaluation,
    required this.isTeacher,
    this.canEvaluate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(
                    _getStatusIcon(),
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assessment.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (categoryName != null) ...[
                        Text(
                          'Categoría: $categoryName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        assessment.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Criterios: ${assessment.criteria.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
                if (assessment.startDate != null)
                  Text(
                    'Inicio: ${_formatDate(assessment.startDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
            if (assessment.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Fin: ${_formatDate(assessment.endDate!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (assessment.status) {
      case AssessmentStatus.draft:
        return Icons.edit_outlined;
      case AssessmentStatus.active:
        return Icons.play_arrow;
      case AssessmentStatus.completed:
        return Icons.check_circle;
      case AssessmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;
    
    switch (assessment.status) {
      case AssessmentStatus.draft:
        chipColor = Colors.grey;
        statusText = 'Borrador';
        break;
      case AssessmentStatus.active:
        chipColor = Colors.green;
        statusText = 'Activo';
        break;
      case AssessmentStatus.completed:
        chipColor = Colors.blue;
        statusText = 'Completado';
        break;
      case AssessmentStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isTeacher) {
      return Row(
        children: [
          if (assessment.status == AssessmentStatus.draft) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onActivate,
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Activar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (assessment.status == AssessmentStatus.active) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onDeactivate,
                icon: const Icon(Icons.stop, size: 16),
                label: const Text('Finalizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (assessment.status == AssessmentStatus.completed) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onViewResults,
                icon: const Icon(Icons.analytics, size: 16),
                label: const Text('Ver Resultados'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            tooltip: 'Eliminar',
          ),
        ],
      );
    } else {
      // Botones para estudiantes
      if (canEvaluate && assessment.status == AssessmentStatus.active) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onStartEvaluation,
            icon: const Icon(Icons.rate_review, size: 16),
            label: const Text('Comenzar Evaluación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      } else if (assessment.status == AssessmentStatus.completed) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onViewResults,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Ver Resultados'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: null,
            child: Text(
              assessment.status == AssessmentStatus.draft 
                  ? 'Evaluación no iniciada'
                  : 'Evaluación no disponible',
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
