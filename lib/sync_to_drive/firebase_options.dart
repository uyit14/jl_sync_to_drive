// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9Ka89VqGqjxTpCJgKW2G5GlznGdL8KKc',
    appId: '1:265023315816:android:eb2832df1eee8c8201c0dd',
    messagingSenderId: '265023315816',
    projectId: 'jl-sync-to-drive',
    storageBucket: 'jl-sync-to-drive.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsxbxGOvLQx1flTjeDVVmS878mPHnyPUg',
    appId: '1:265023315816:ios:8c052a8d7539540801c0dd',
    messagingSenderId: '265023315816',
    projectId: 'jl-sync-to-drive',
    storageBucket: 'jl-sync-to-drive.appspot.com',
    androidClientId: '265023315816-4cjqtks473mjnr0r4heesqj04hujduq7.apps.googleusercontent.com',
    iosClientId: '265023315816-spnod7nahpu8qth74u38lps1jv7b5fnn.apps.googleusercontent.com',
    iosBundleId: 'com.example.jlSyncToDrive',
  );
}
