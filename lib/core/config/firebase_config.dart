import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for different platforms
class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBev1zKuvBDS3gRkjrY3_frjrhqCUbxMwM',
    appId: '1:916354627144:web:06c8f626d4f6d1d1754a7d',
    messagingSenderId: '916354627144',
    projectId: 'mad-project-77dd3',
    authDomain: 'mad-project-77dd3.firebaseapp.com',
    storageBucket: 'mad-project-77dd3.firebasestorage.app',
    measurementId: 'G-CNX8L4JV31',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBev1zKuvBDS3gRkjrY3_frjrhqCUbxMwM',
    appId: '1:916354627144:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '916354627144',
    projectId: 'mad-project-77dd3',
    storageBucket: 'mad-project-77dd3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBev1zKuvBDS3gRkjrY3_frjrhqCUbxMwM',
    appId: '1:916354627144:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '916354627144',
    projectId: 'mad-project-77dd3',
    storageBucket: 'mad-project-77dd3.firebasestorage.app',
    iosBundleId: 'com.example.comsatsGpt',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBev1zKuvBDS3gRkjrY3_frjrhqCUbxMwM',
    appId: '1:916354627144:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '916354627144',
    projectId: 'mad-project-77dd3',
    storageBucket: 'mad-project-77dd3.firebasestorage.app',
    iosBundleId: 'com.example.comsatsGpt',
  );
}
