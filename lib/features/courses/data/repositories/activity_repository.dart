import '../datasources/i_activity_source.dart';

import '../../domain/models/activity.dart';
import '../../domain/repositories/i_activity_repository.dart';

class ActivityRepository implements IActivityRepository {
  final IActivityDataSource _dataSource;

  ActivityRepository(this._dataSource);

  @override
  Future<List<Activity>> getActivitiesByCourseId(String courseId) async {
    return await _dataSource.getActivitiesByCourseId(courseId);
  }

  @override
  Future<bool> addActivity(Activity activity) async {
    return await _dataSource.addActivity(activity);
  }

  @override
  Future<bool> updateActivity(Activity activity) async {
    return await _dataSource.updateActivity(activity);
  }

  @override
  Future<bool> deleteActivity(String activityId) async {
    return await _dataSource.deleteActivity(activityId);
  }

  @override
  Future<Activity?> getActivityById(String activityId) async {
    return await _dataSource.getActivityById(activityId);
  }

  @override
  Future<List<Activity>> getActivitiesByCategoryId(String categoryId) async {
    return await _dataSource.getActivitiesByCategoryId(categoryId);
  }
}
