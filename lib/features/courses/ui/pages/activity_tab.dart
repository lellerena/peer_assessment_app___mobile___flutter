import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../domain/models/course.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/category.dart';
import '../../domain/models/submission.dart';
import '../controllers/activity_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/submission_controller.dart';
import '../../domain/usecases/activity_usecase.dart';
import '../../domain/usecases/submission_usecase.dart';
import '../widgets/activity_list_tile.dart';
import '../widgets/add_edit_activity_dialog.dart';
import '../pages/student_submission_page.dart';
import '../pages/teacher_submissions_page.dart';
import '../../../../core/i_local_preferences.dart';

class ActivityTab extends StatefulWidget {
  final Course course;
  final bool isTeacher;

  const ActivityTab({Key? key, required this.course, required this.isTeacher})
    : super(key: key);

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  @override
  void initState() {
    super.initState();
    // Register ActivityController
    final String activityTag = 'activity_controller_${widget.course.id}';
    if (!Get.isRegistered<ActivityController>(tag: activityTag)) {
      Get.put(
        ActivityController(Get.find<ActivityUseCase>(), widget.course.id),
        tag: activityTag,
      );
    }

    // Register SubmissionController if not registered
    if (!Get.isRegistered<SubmissionController>()) {
      Get.put(SubmissionController(Get.find<SubmissionUseCase>()));
    }
  }

  @override
  void dispose() {
    final String activityTag = 'activity_controller_${widget.course.id}';
    if (Get.isRegistered<ActivityController>(tag: activityTag)) {
      Get.delete<ActivityController>(tag: activityTag);
    }
    super.dispose();
  }

  void _showAddEditDialog(
    BuildContext context,
    ActivityController controller,
    List<Category> categories, [
    Activity? activity,
  ]) {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create at least one category first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddEditActivityDialog(
        activity: activity,
        courseId: widget.course.id,
        categories: categories,
        onSave: (newActivity) {
          if (activity == null) {
            controller.addActivity(newActivity);
          } else {
            controller.updateActivity(newActivity);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ActivityController controller,
    Activity activity,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${activity.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                controller.deleteActivity(activity.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Método para navegar a la página de entrega para estudiantes
  void _navigateToSubmissionPage(Activity activity, Category? category) async {
    final ILocalPreferences prefs = Get.find();
    final rawUser = await prefs.retrieveData<String>('user');
    if (rawUser != null) {
      final userData = json.decode(rawUser);
      final userId = userData['id'] as String?;

      if (userId != null) {
        Get.to(
          () => StudentSubmissionPage(
            activity: activity,
            studentId: userId,
            group: category?.groups.isEmpty ?? true
                ? null
                : category?.groups.firstWhereOrNull(
                    (group) => group.studentIds.contains(userId),
                  ),
          ),
        );
      }
    }
  }

  // Método para navegar a la página de visualización de entregas para profesores
  void _navigateToTeacherSubmissionsPage(Activity activity) {
    Get.to(() => TeacherSubmissionsPage(activity: activity));
  }

  @override
  Widget build(BuildContext context) {
    final String activityTag = 'activity_controller_${widget.course.id}';
    final String categoryTag = 'category_controller_${widget.course.id}';
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with counter and reload button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: GetBuilder<ActivityController>(
                    tag: activityTag,
                    builder: (_) {
                      final controller = Get.find<ActivityController>(
                        tag: activityTag,
                      );
                      return Obx(
                        () => Text(
                          'Activities (${controller.activities.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Reload',
                  onPressed: () {
                    final controller = Get.find<ActivityController>(
                      tag: activityTag,
                    );
                    controller.getActivities();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          // Activities content
          Expanded(
            child: GetBuilder<ActivityController>(
              tag: activityTag,
              builder: (_) {
                final controller = Get.find<ActivityController>(
                  tag: activityTag,
                );
                final categoryController = Get.find<CategoryController>(
                  tag: categoryTag,
                );
                return Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: scheme.error,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 18,
                              color: scheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: scheme.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.getActivities(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 80,
                            color: scheme.secondary,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No activities found.',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isTeacher
                                ? 'Add a new activity for this course using the button below.'
                                : 'There are no activities for this course yet.',
                            style: TextStyle(color: scheme.secondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: controller.activities.length,
                    itemBuilder: (context, index) {
                      final activity = controller.activities[index];

                      // Find the category for this activity
                      String? categoryName;
                      final category = categoryController.categories
                          .firstWhereOrNull(
                            (cat) => cat.id == activity.categoryId,
                          );
                      if (category != null) {
                        categoryName = category.name;
                      }

                      return ActivityListTile(
                        activity: activity,
                        categoryName: categoryName,
                        onEdit: widget.isTeacher
                            ? () => _showAddEditDialog(
                                context,
                                controller,
                                categoryController.categories,
                                activity,
                              )
                            : null,
                        onDelete: widget.isTeacher
                            ? () => _showDeleteConfirmation(
                                context,
                                controller,
                                activity,
                              )
                            : null,
                        onSubmit: !widget.isTeacher
                            ? () =>
                                  _navigateToSubmissionPage(activity, category)
                            : null,
                        onViewSubmissions: widget.isTeacher
                            ? () => _navigateToTeacherSubmissionsPage(activity)
                            : null,
                        isTeacher: widget.isTeacher,
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isTeacher
          ? GetBuilder<CategoryController>(
              tag: categoryTag,
              builder: (categoryController) {
                return FloatingActionButton(
                  heroTag: "activity_fab_${widget.course.id}",
                  backgroundColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    final activityController = Get.find<ActivityController>(
                      tag: activityTag,
                    );
                    _showAddEditDialog(
                      context,
                      activityController,
                      categoryController.categories,
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                );
              },
            )
          : null,
    );
  }
}
