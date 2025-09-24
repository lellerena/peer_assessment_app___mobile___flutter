import 'package:get/get.dart';
import '../../domain/models/activity.dart';
import '../../domain/usecases/activity_usecase.dart';

class ActivityController extends GetxController {
  final RxList<Activity> _activities = <Activity>[].obs;
  final ActivityUseCase activityUseCase;
  final String courseId;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  ActivityController(this.activityUseCase, this.courseId);

  List<Activity> get activities => _activities;

  @override
  void onInit() {
    super.onInit();
    getActivities();
  }

  Future<void> getActivities() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _activities.value = await activityUseCase.getActivitiesByCourseId(
        courseId,
      );
    } catch (e) {
      print("Error getting activities: $e");
      errorMessage.value = "Error loading activities: $e";
      _activities.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      isLoading.value = true;
      await activityUseCase.addActivity(activity);
      await getActivities(); // Refresh the list
    } catch (e) {
      print("Error adding activity: $e");
      errorMessage.value = "Error adding activity: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      isLoading.value = true;
      await activityUseCase.updateActivity(activity);
      await getActivities(); // Refresh the list
    } catch (e) {
      print("Error updating activity: $e");
      errorMessage.value = "Error updating activity: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      isLoading.value = true;
      await activityUseCase.deleteActivity(activityId);
      await getActivities(); // Refresh the list
    } catch (e) {
      print("Error deleting activity: $e");
      errorMessage.value = "Error deleting activity: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
