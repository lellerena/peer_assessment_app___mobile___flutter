import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user.dart';

abstract class IAuthLocalDataSource {
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  Future<User?> currentUser();
  Future<List<User>> getUsersByIds(List<String> ids);
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  final SharedPreferences _prefs;
  List<User> _users = [];

  AuthLocalDataSource(this._prefs) {
    _init();
  }

  Future<void> _init() async {
    final jsonString = await rootBundle.loadString('assets/data/users.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _users = jsonList.map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<User?> signIn(String email, String password) async {
    await _init(); // Make sure users are loaded
    try {
      final user = _users.firstWhere(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() &&
            user.password == password,
      );
      await _prefs.setString('currentUserId', user.id ?? '');
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove('currentUserId');
  }

  @override
  Future<User?> currentUser() async {
    await _init(); // Make sure users are loaded
    final userId = _prefs.getString('currentUserId');
    if (userId == null) {
      return null;
    }
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<User>> getUsersByIds(List<String> ids) async {
    await _init(); // Make sure users are loaded
    return _users.where((u) => ids.contains(u.id)).toList();
  }
}
