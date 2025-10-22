import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../controllers/reports_controller.dart';
import '../../domain/usecases/activity_usecase.dart';
import '../../domain/usecases/grade_usecase.dart';
import '../../domain/usecases/category_usecase.dart';

class ReportsTab extends StatefulWidget {
  final Course course;

  const ReportsTab({super.key, required this.course});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  int _selectedReportType = 0; // 0: Activity Average, 1: Group Average, 2: Student Average, 3: Detailed Results
  late ReportsController _reportsController;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de reportes para este curso
    Get.lazyPut(
      () => ReportsController(
        Get.find<ActivityUseCase>(),
        Get.find<GradeUsecase>(),
        Get.find<CategoryUseCase>(),
        widget.course.id,
      ),
      tag: 'reports_${widget.course.id}',
      fenix: true,
    );
    _reportsController = Get.find<ReportsController>(tag: 'reports_${widget.course.id}');
  }

  @override
  void dispose() {
    // No necesitamos hacer dispose del controlador ya que GetX lo maneja
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_reportsController.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (_reportsController.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar reportes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _reportsController.errorMessage.value,
                  style: TextStyle(color: Colors.red.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _reportsController.refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del curso
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reportes - ${widget.course.name}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _reportsController.refresh(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar datos',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selector de tipo de reporte
            Text(
              'Tipo de Reporte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _ReportTypeSelector(
                    title: 'Reporte por Actividades',
                    subtitle: 'Ver promedios de actividades del curso',
                    icon: Icons.analytics,
                    isSelected: _selectedReportType == 0,
                    onTap: () => setState(() => _selectedReportType = 0),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _ReportTypeSelector(
                    title: 'Reporte por Grupos',
                    subtitle: 'Ver promedios de grupos del curso',
                    icon: Icons.group,
                    isSelected: _selectedReportType == 1,
                    onTap: () => setState(() => _selectedReportType = 1),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _ReportTypeSelector(
                    title: 'Reporte por Estudiantes',
                    subtitle: 'Ver promedios de estudiantes inscritos',
                    icon: Icons.person,
                    isSelected: _selectedReportType == 2,
                    onTap: () => setState(() => _selectedReportType = 2),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _ReportTypeSelector(
                    title: 'Resultados Detallados',
                    subtitle: 'Ver resultados completos por criterio',
                    icon: Icons.list_alt,
                    isSelected: _selectedReportType == 3,
                    onTap: () => setState(() => _selectedReportType = 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contenido del reporte seleccionado
            _buildReportContent(),
          ],
        ),
      );
    });
  }

  Widget _buildReportContent() {
    switch (_selectedReportType) {
      case 0:
        return _buildActivityAverageReport();
      case 1:
        return _buildGroupAverageReport();
      case 2:
        return _buildStudentAverageReport();
      case 3:
        return _buildDetailedResultsReport();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActivityAverageReport() {
    final activities = _reportsController.activities;
    
    if (activities.isEmpty) {
      return _PurpleCard(
        child: Column(
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay actividades en este curso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las actividades aparecerán aquí cuando se creen',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _PurpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promedios por Actividad (${activities.length} actividades)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) {
            final average = _reportsController.getActivityAverage(activity.id);
            final grades = _reportsController.getGradesForActivity(activity.id);
            
            return _ActivityReportItem(
              activityName: activity.title,
              average: average,
              totalStudents: grades.length,
              color: _getColorForActivity(activity.id),
              date: activity.date,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGroupAverageReport() {
    final groups = _reportsController.allGroups;
    
    if (groups.isEmpty) {
      return _PurpleCard(
        child: Column(
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay grupos creados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea categorías y grupos en la pestaña "Categorías" para ver reportes',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _PurpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promedios por Grupo (${groups.length} grupos)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...groups.map((group) {
            final average = _reportsController.getGroupAverage(group.id);
            final grades = _reportsController.getGradesForGroup(group.id);
            final categoryName = _reportsController.getGroupCategory(group.id);
            
            return _GroupReportItem(
              groupName: group.name,
              categoryName: categoryName ?? 'Sin categoría',
              average: average,
              totalStudents: group.studentIds.length,
              gradedStudents: grades.length,
              color: _getColorForGroup(group.id),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudentAverageReport() {
    final students = _reportsController.getStudentsWithGrades();
    final activities = _reportsController.activities;
    
    if (students.isEmpty) {
      return _PurpleCard(
        child: Column(
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes con calificaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los estudiantes aparecerán aquí cuando tengan calificaciones',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _PurpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reporte por Estudiantes (${students.length} estudiantes)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Estudiante')),
                ...activities.map((activity) => DataColumn(
                  label: Text(
                    activity.title,
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
                const DataColumn(label: Text('Promedio')),
              ],
              rows: students.map((studentId) {
                final average = _reportsController.getStudentAverage(studentId);
                
                return DataRow(
                  cells: [
                    DataCell(Text(studentId)),
                    ...activities.map((activity) {
                      final grade = _reportsController.getStudentGradeForActivity(studentId, activity.id);
                      return DataCell(Text(grade.toStringAsFixed(1)));
                    }),
                    DataCell(Text(average.toStringAsFixed(1))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedResultsReport() {
    final activities = _reportsController.activities;
    final students = _reportsController.getStudentsWithGrades();
    
    if (activities.isEmpty || students.isEmpty) {
      return _PurpleCard(
        child: Column(
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay datos para mostrar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Necesitas actividades y calificaciones para ver resultados detallados',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return _PurpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados Detallados por Criterios',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Estudiante')),
                const DataColumn(label: Text('Actividad')),
                const DataColumn(label: Text('Creatividad')),
                const DataColumn(label: Text('Contenido')),
                const DataColumn(label: Text('Presentación')),
                const DataColumn(label: Text('Nota')),
              ],
              rows: _buildDetailedRows(students, activities),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _buildDetailedRows(List<String> students, List<dynamic> activities) {
    final rows = <DataRow>[];
    
    for (final studentId in students) {
      for (final activity in activities) {
        final criterias = _reportsController.getGradeCriteria(studentId, activity.id);
        final nota = _reportsController.calculateCriteriaAverage(criterias);
        
        // Solo mostrar filas que tengan al menos un criterio calificado
        if (criterias.values.any((v) => v > 0)) {
          rows.add(
            DataRow(
              cells: [
                DataCell(Text(studentId)),
                DataCell(Text(activity.title)),
                DataCell(Text(criterias['creatividad']!.toStringAsFixed(1))),
                DataCell(Text(criterias['contenido']!.toStringAsFixed(1))),
                DataCell(Text(criterias['presentacion']!.toStringAsFixed(1))),
                DataCell(Text(nota.toStringAsFixed(1))),
              ],
            ),
          );
        }
      }
    }
    
    return rows;
  }

  Color _getColorForActivity(String activityId) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    return colors[activityId.hashCode % colors.length];
  }

  Color _getColorForGroup(String groupId) {
    final colors = [Colors.purple, Colors.teal, Colors.indigo, Colors.amber, Colors.pink];
    return colors[groupId.hashCode % colors.length];
  }
}

class _ActivityReportItem extends StatelessWidget {
  final String activityName;
  final double average;
  final int totalStudents;
  final Color color;
  final DateTime date;

  const _ActivityReportItem({
    required this.activityName,
    required this.average,
    required this.totalStudents,
    required this.color,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activityName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fecha: ${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$totalStudents estudiantes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupReportItem extends StatelessWidget {
  final String groupName;
  final String categoryName;
  final double average;
  final int totalStudents;
  final int gradedStudents;
  final Color color;

  const _GroupReportItem({
    required this.groupName,
    required this.categoryName,
    required this.average,
    required this.totalStudents,
    required this.gradedStudents,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Categoría: $categoryName',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$gradedStudents/$totalStudents estudiantes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentReportItem extends StatelessWidget {
  final String studentId;
  final double average;
  final int totalActivities;
  final String groupName;

  const _StudentReportItem({
    required this.studentId,
    required this.average,
    required this.totalActivities,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estudiante: $studentId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grupo: $groupName',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                average.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '$totalActivities actividades',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PurpleCard extends StatelessWidget {
  final Widget child;

  const _PurpleCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReportTypeSelector extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeSelector({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}