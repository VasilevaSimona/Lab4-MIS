import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzJhuC5lOLNrzbBGT6b1FpBSTZGb1HXzk',
    appId: '1:571272026348:android:f15f720dbcb090380badc9',
    messagingSenderId: '571272026348',
    projectId: 'flutter-firebase-aacfe',
    storageBucket: 'flutter-firebase-aacfe.appspot.com',
  );
}

