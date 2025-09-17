import 'dart:convert';

import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/i_local_preferences.dart';
import '../../../domain/models/user_public.dart';
import '../../../domain/models/user.dart';
import 'i_authentication_source.dart';

class AuthenticationSourceServiceRoble implements IAuthenticationSource {
  final http.Client httpClient;
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/scheduler_51d857e7d5';

  AuthenticationSourceServiceRoble({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"email": email, "password": password}),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      logInfo(response.body);
      final data = jsonDecode(response.body);
      final token = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = UserPublic.fromJson(data['user']);
      final userId = user.id;
      final ILocalPreferences sharedPreferences = Get.find();
      await sharedPreferences.storeData('token', token);
      await sharedPreferences.storeData('refreshToken', refreshToken);
      await sharedPreferences.storeData('user', jsonEncode(user.toJson()));
      if (userId != null) {
        await sharedPreferences.storeData('userId', userId);
      } else {
        // Evita TypeError al intentar guardar null en storage
        await sharedPreferences.removeData('userId');
      }
      logInfo(
        "Token: $token"
            "\nRefresh Token: $refreshToken",
        "\nUser: ${user.toJson()}",
      );
      return Future.value(true);
    } else {
      final Map<String, dynamic> body = json.decode(response.body);
      final String errorMessage = body['message'];
      logError(
        "Login endpoint got error code ${response.statusCode}: $errorMessage",
      );
      return Future.error('Error $errorMessage');
    }
  }

  @override
  Future<bool> signUp(User user) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": user.email,
        "name": user.email,
        "password": user.password,
      }),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      return Future.value(true);
    } else {
      logError(response.body);
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> messages = body['message'];
      final String errorMessage = messages.join(" ");
      logError(
        "signUp endpoint got error code ${response.statusCode} - $errorMessage",
      );
      return Future.error('Error $errorMessage');
    }
  }

  @override
  Future<bool> logOut() async {
    final ILocalPreferences sharedPreferences = Get.find();
    try {
      final token = await sharedPreferences.retrieveData<String>('token');
      if (token != null) {
        await httpClient
            .post(
              Uri.parse("$baseUrl/logout"),
              headers: <String, String>{'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 2));
      }
    } catch (e) {
      logError('Logout request failed or timed out: $e');
    } finally {
      await sharedPreferences.removeData('token');
      await sharedPreferences.removeData('refreshToken');
      await sharedPreferences.removeData('user');
      await sharedPreferences.removeData('userId');
    }
    logInfo("Logged out locally");
    return Future.value(true);
  }

  @override
  Future<bool> validate(String email, String validationCode) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/verify-email"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "email": email, // Assuming validationCode is the email
        "code": validationCode,
      }),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "verifyEmail endpoint got error code ${response.statusCode} $errorMessage for email: $email",
      );
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> refreshToken() async {
    final ILocalPreferences sharedPreferences = Get.find();
    final refreshToken = await sharedPreferences.retrieveData<String>(
      'refreshToken',
    );
    if (refreshToken == null) {
      logError("No refresh token found, cannot refresh.");
      return Future.error('No refresh token found');
    }

    final response = await http.post(
      Uri.parse("$baseUrl/refresh-token"),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'refreshToken': refreshToken}),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final newToken = data['accessToken'];
      await sharedPreferences.storeData('token', newToken);
      logInfo("Token refreshed successfully");
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "refreshToken endpoint got error code ${response.statusCode} $errorMessage for refreshToken: $refreshToken",
      );
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"email": email}),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "forgotPassword endpoint got error code ${response.statusCode} $errorMessage for email: $email",
      );
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  ) async {
    return Future.value(true);
  }

  @override
  Future<bool> verifyToken() async {
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    if (token == null) {
      logError("No token found, cannot verify.");
      return Future.value(false);
    }
    //logInfo("Verifying token: $token");
    final response = await httpClient.get(
      Uri.parse("$baseUrl/verify-token"),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );
    logInfo(response.statusCode);
    if (response.statusCode == 200) {
      logInfo("Token is valid");
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "verifyToken endpoint got error code ${response.statusCode} $errorMessage for token: $token",
      );
      return Future.value(false);
    }
  }
}
