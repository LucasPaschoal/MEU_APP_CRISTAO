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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAkboACqj6Ka7933NyjNIU7amiATyZzLk8",
    authDomain: "meuappcristao.firebaseapp.com",
    projectId: "meuappcristao",
    storageBucket: "meuappcristao.firebasestorage.app",
    messagingSenderId: "822885725408",
    appId: "1:822885725408:web:c405d397147ed1ba898c85",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAkboACqj6Ka7933NyjNIU7amiATyZzLk8",
    authDomain: "meuappcristao.firebaseapp.com",
    projectId: "meuappcristao",
    storageBucket: "meuappcristao.firebasestorage.app",
    messagingSenderId: "822885725408",
    appId: "1:822885725408:web:c405d397147ed1ba898c85",
  );
}
