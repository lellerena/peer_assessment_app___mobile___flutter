import '../models/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  final IActivityRepository _repository;

  ActivityUseCase(this._repository);

  Future<List<Activity>> getActivitiesByCourseId(String courseId) async =>
      await _repository.getActivitiesByCourseId(courseId);

  Future<bool> addActivity(Activity activity) async =>
      await _repository.addActivity(activity);

  Future<bool> updateActivity(Activity activity) async =>
      await _repository.updateActivity(activity);

  Future<bool> deleteActivity(String activityId) async =>
      await _repository.deleteActivity(activityId);

  Future<Activity?> getActivityById(String activityId) async =>
      await _repository.getActivityById(activityId);

  Future<List<Activity>> getActivitiesByCategoryId(String categoryId) async =>
      await _repository.getActivitiesByCategoryId(categoryId);
}
