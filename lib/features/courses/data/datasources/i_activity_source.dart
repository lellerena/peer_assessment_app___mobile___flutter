import '../../domain/models/activity.dart';

abstract class IActivityDataSource {
  Future<List<Activity>> getActivitiesByCourseId(String courseId);
  Future<bool> addActivity(Activity activity);
  Future<bool> updateActivity(Activity activity);
  Future<bool> deleteActivity(String activityId);
  Future<Activity?> getActivityById(String activityId);
  Future<List<Activity>> getActivitiesByCategoryId(String categoryId);
}
