import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart' as model;

ValueNotifier<UserService> userService = ValueNotifier(UserService());

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      'uid',
      (userData['uid'] as String?) ?? currentUser?.uid ?? '',
    );
    await preferences.setString(
      'refreshToken',
      userData['refreshToken'] as String? ?? '',
    );

    // Sync to Firestore Users collection if authenticated
    final uid = preferences.getString('uid') ?? currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      final email = preferences.getString('email') ?? '';
      final firstName = preferences.getString('firstName') ?? '';
      if (email.isNotEmpty || firstName.isNotEmpty) {
        try {
          await _firestore.collection('Users').doc(uid).set({
            'uid': uid,
            'email': email,
            'firstName': firstName.isNotEmpty ? firstName : email.split('@').first,
            'lastName': preferences.getString('lastName') ?? '',
            'username': preferences.getString('username') ?? '',
          }, SetOptions(merge: true));
        } catch (_) {}
      }
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final preferences = await SharedPreferences.getInstance();

    return {
      'id': preferences.getInt('id') ?? 0,
      'uid': preferences.getString('uid') ?? currentUser?.uid ?? '',
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
  Future<model.User> getUser() async {
    return model.User.fromJson(await getUserData());
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    try {
      await firebaseAuth.signOut();
    } catch (_) {}
  }

  // Firebase Authentication methods from Lab Activity
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> updateUsername({required String username}) async {
    await currentUser!.updateDisplayName(username);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('username', username);
    await preferences.setString('firstName', username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    final uid = currentUser?.uid;

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();

    // Delete user from Firestore Users collection
    if (uid != null && uid.isNotEmpty) {
      try {
        await _firestore.collection('Users').doc(uid).delete();
      } catch (_) {}
    }

    try {
      final q = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
      for (final doc in q.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}

    await logout();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
