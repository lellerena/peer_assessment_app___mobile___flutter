import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/course.dart';
import '../controllers/category_controller.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/course_controller.dart';

class ReportsTab extends StatefulWidget {
  final Course course;

  const ReportsTab({super.key, required this.course});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  int _selectedReportType = 0; // 0: Activity Average, 1: Group Average, 2: Student Average, 3: Detailed Results
  List<Map<String, String>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final controller = Get.find<CourseController>();
      final students = await controller.getUsersByIds(widget.course.studentIds);
      if (mounted) {
        setState(() {
          _students = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading students: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getSimpleActivityReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _PurpleCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _PurpleCard(
            child: Column(
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar reportes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final activities = snapshot.data ?? [];
        
        if (activities.isEmpty) {
          return _PurpleCard(
            child: Column(
              children: [
                Icon(Icons.analytics, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay actividades creadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea actividades en la pestaña "Actividades" para ver reportes',
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
              Row(
                children: [
                  Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Reporte por Actividades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...activities.map((activity) {
                final averageGrade = activity['averageGrade'] ?? 0.0;
                final gradedStudents = activity['gradedStudents'] ?? 0;
                final totalStudents = activity['totalStudents'] ?? 0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReportCard(
                    title: activity['name'] ?? 'Actividad Desconocida',
                    value: averageGrade.toStringAsFixed(1),
                    subtitle: 'Calificados: $gradedStudents/$totalStudents estudiantes',
                    color: _getColorForActivity(activity['id'] ?? ''),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupAverageReport() {
    final String tag = 'category_controller_${widget.course.id}';
    return GetBuilder<CategoryController>(
      tag: tag,
      builder: (controller) {
        return Obx(() {
          final categories = controller.categories;
          final allGroups = categories.expand((cat) => cat.groups).toList();
          
          if (allGroups.isEmpty) {
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
                Row(
                  children: [
                    Icon(Icons.group, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Reporte por Grupos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...allGroups.map((group) {
                  // Generar nota aleatoria entre 6.0 y 10.0
                  final random = (6.0 + (group.id.hashCode % 40) / 10).toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReportCard(
                      title: group.name,
                      value: random,
                      subtitle: '${group.studentIds.length} estudiantes - Promedio general',
                      color: _getColorForGroup(group.id),
                    ),
                  );
                }),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildStudentAverageReport() {
    if (_isLoading) {
      return const _PurpleCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_students.isEmpty) {
      return _PurpleCard(
        child: Column(
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes inscritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los estudiantes aparecerán aquí cuando se inscriban al curso',
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
          Row(
            children: [
              Icon(Icons.person, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Reporte por Estudiantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._students.map((student) {
            // Generar nota aleatoria entre 6.0 y 10.0
            final random = (6.0 + (student['id']?.hashCode ?? 0) % 40 / 10).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StudentReportCard(
                name: student['name'] ?? 'Estudiante',
                email: student['email'] ?? '',
                average: random,
                group: _getStudentGroup(student['id'] ?? ''),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailedResultsReport() {
    if (_isLoading) {
      return const _PurpleCard(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_students.isEmpty) {
      return _PurpleCard(
        child: Column(
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay estudiantes para mostrar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los resultados detallados aparecerán cuando haya estudiantes inscritos',
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
          Row(
            children: [
              Icon(Icons.list_alt, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Resultados Detallados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._students.take(3).map((student) {
            final groupName = _getStudentGroup(student['id'] ?? '');
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DetailedResultCard(
                groupName: groupName,
                studentName: student['name'] ?? 'Estudiante',
                criteria: [
                  {'name': 'Creatividad', 'score': (6.0 + (student['id']?.hashCode ?? 0) % 40 / 10).toStringAsFixed(1)},
                  {'name': 'Presentación', 'score': (6.0 + ((student['id']?.hashCode ?? 0) + 1) % 40 / 10).toStringAsFixed(1)},
                  {'name': 'Contenido', 'score': (6.0 + ((student['id']?.hashCode ?? 0) + 2) % 40 / 10).toStringAsFixed(1)},
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Métodos auxiliares
  Color _getColorForActivity(String activityId) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.teal];
    return colors[activityId.hashCode % colors.length];
  }

  Future<List<Map<String, dynamic>>> _getSimpleActivityReports() async {
    try {
      print('=== OBTENIENDO REPORTES SIMPLES DE ACTIVIDADES ===');
      
      // Usar el controlador de actividades existente para obtener datos reales
      final String tag = 'assessment_controller_${widget.course.id}';
      final controller = Get.find<AssessmentController>(tag: tag);
      
      // Esperar a que se carguen las actividades
      await Future.delayed(const Duration(milliseconds: 500));
      
      final assessments = controller.assessments;
      print('Actividades encontradas: ${assessments.length}');
      
      // Convertir a formato simple para reportes
      final List<Map<String, dynamic>> activityReports = [];
      
      for (final assessment in assessments) {
        // Por ahora mostrar 0, pero en el futuro se puede conectar con grades
        activityReports.add({
          'id': assessment.id,
          'name': assessment.name,
          'averageGrade': 0.0, // TODO: Conectar con tabla grades
          'gradedStudents': 0, // TODO: Conectar con tabla grades
          'totalStudents': 0,  // TODO: Conectar con tabla grades
        });
      }
      
      print('Reportes de actividades generados: ${activityReports.length}');
      return activityReports;
    } catch (e) {
      print('Error obteniendo reportes simples: $e');
      return [];
    }
  }

  Color _getColorForGroup(String groupId) {
    final colors = [Colors.purple, Colors.teal, Colors.indigo, Colors.amber, Colors.pink];
    return colors[groupId.hashCode % colors.length];
  }

  String _getStudentGroup(String studentId) {
    final String tag = 'category_controller_${widget.course.id}';
    try {
      final controller = Get.find<CategoryController>(tag: tag);
      for (final category in controller.categories) {
        for (final group in category.groups) {
          if (group.studentIds.contains(studentId)) {
            return group.name;
          }
        }
      }
    } catch (e) {
      print("Error getting student group: $e");
    }
    return 'Sin grupo';
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 20,
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
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.black54,
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

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentReportCard extends StatelessWidget {
  final String name;
  final String email;
  final String average;
  final String group;

  const _StudentReportCard({
    required this.name,
    required this.email,
    required this.average,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              average,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedResultCard extends StatelessWidget {
  final String groupName;
  final String studentName;
  final List<Map<String, String>> criteria;

  const _DetailedResultCard({
    required this.groupName,
    required this.studentName,
    required this.criteria,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...criteria.map((criterion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  criterion['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    criterion['score']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
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
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
