import 'package:get/get.dart';
import '../../../core/entities/course.dart';
import '../../../core/entities/user.dart';
import '../dummy_data.dart';

class UserCoursesController extends GetxController {
  // Usuario actual simulado
  final currentUser = User(id: 'u1', name: 'Jhon').obs;

  var courses = dummyCourses.obs;
  var users = dummyUsers.obs;

  // Cursos donde el usuario está inscrito
  List<Course> get userCourses {
    return courses
        .where((c) => c.enrolledUserIds.contains(currentUser.value.id))
        .toList();
  }

  List<User> getUsersFromIds(List<String> ids) {
    return users.where((u) => ids.contains(u.id)).toList();
  }
}
