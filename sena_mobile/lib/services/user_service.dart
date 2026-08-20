import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final apiHost = host;
    if (apiHost == null || apiHost.isEmpty) {
      throw StateError('HOST is not configured in assets/.env');
    }

    final response = await http.post(
      Uri.parse('$apiHost/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await saveUserData(data);
      return data;
    }

    throw Exception(response.body);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt('id', (userData['id'] as num?)?.toInt() ?? 0);
    await preferences.setString(
      'username',
      userData['username'] as String? ?? '',
    );
    await preferences.setString('email', userData['email'] as String? ?? '');
    await preferences.setString(
      'firstName',
      userData['firstName'] as String? ?? '',
    );
    await preferences.setString(
      'lastName',
      userData['lastName'] as String? ?? '',
    );
    await preferences.setString(
      'gender',
      userData['gender'] as String? ?? '',
    );
    await preferences.setString('image', userData['image'] as String? ?? '');
    await preferences.setString(
      'accessToken',
      (userData['accessToken'] as String?) ??
          (userData['token'] as String?) ??
          '',
    );
    await preferences.setString(
      'refreshToken',
      userData['refreshToken'] as String? ?? '',
    );
  }

  Future<Map<String, dynamic>> getUserData() async {
    final preferences = await SharedPreferences.getInstance();

    return {
      'id': preferences.getInt('id') ?? 0,
      'username': preferences.getString('username') ?? '',
      'email': preferences.getString('email') ?? '',
      'firstName': preferences.getString('firstName') ?? '',
      'lastName': preferences.getString('lastName') ?? '',
      'gender': preferences.getString('gender') ?? '',
      'image': preferences.getString('image') ?? '',
      'accessToken': preferences.getString('accessToken') ?? '',
      'refreshToken': preferences.getString('refreshToken') ?? '',
    };
  }

  // Enhancement 3: Recreate the saved user as a model for the UI.
  Future<User> getUser() async {
    return User.fromJson(await getUserData());
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }
}
