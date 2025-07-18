import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBR8AUNjbCyT8JUivNwFzjn8VBXi6sNw2U',
    appId: '1:254020421967:android:772d78b09bea32fe1edd3a',
    messagingSenderId: '254020421967',
    projectId: 'atlfirebasebackend',
    storageBucket: 'atlfirebasebackend.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbjOVB5HtGEKZcZvcKZnUvrigCXyHdxhk',
    appId: '1:254020421967:ios:e440eb2d038edfff1edd3a',
    messagingSenderId: '254020421967',
    projectId: 'atlfirebasebackend',
    storageBucket: 'atlfirebasebackend.firebasestorage.app',
    iosBundleId: 'com.example.atlMembership',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBbjOVB5HtGEKZcZvcKZnUvrigCXyHdxhk',
    appId: '1:254020421967:ios:e440eb2d038edfff1edd3a',
    messagingSenderId: '254020421967',
    projectId: 'atlfirebasebackend',
    storageBucket: 'atlfirebasebackend.firebasestorage.app',
  );
}
