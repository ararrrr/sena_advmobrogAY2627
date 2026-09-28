// File generated for advmobprog-firebase-6d376
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC8UUCbJ54GAVcSv6rzcJLT-M3nnU45YOc',
    appId: '1:754439049589:web:54cdd3e6e5abbeb7c1433c',
    messagingSenderId: '754439049589',
    projectId: 'advmobprog-firebase-6d376',
    authDomain: 'advmobprog-firebase-6d376.firebaseapp.com',
    storageBucket: 'advmobprog-firebase-6d376.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8UUCbJ54GAVcSv6rzcJLT-M3nnU45YOc',
    appId: '1:754439049589:android:aaaf2662f4543382c1433c',
    messagingSenderId: '754439049589',
    projectId: 'advmobprog-firebase-6d376',
    storageBucket: 'advmobprog-firebase-6d376.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9Qx0DAh092cuSDXgqO065zuQmedxdxQE',
    appId: '1:754439049589:ios:249c19f651db9abcc1433c',
    messagingSenderId: '754439049589',
    projectId: 'advmobprog-firebase-6d376',
    storageBucket: 'advmobprog-firebase-6d376.firebasestorage.app',
    iosBundleId: 'com.example.senaMobile',
  );
}
