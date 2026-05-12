import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

// Default Firebase configuration
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDummyKeyForDevelopment',
  appId: '1:123456789:android:abcdef123456789',
  messagingSenderId: '123456789',
  projectId: 'riziko-development',
  storageBucket: 'riziko-development.appspot.com',
);

// Platform-specific configuration
FirebaseOptions get currentPlatform {
  if (kIsWeb) {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDummyKeyForDevelopment',
      appId: '1:123456789:web:abcdef123456789',
      projectId: 'riziko-development',
      messagingSenderId: '123456789',
      storageBucket: 'riziko-development.appspot.com',
    );
  }
  
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return const FirebaseOptions(
        apiKey: 'AIzaSyDummyKeyForDevelopment',
        appId: '1:123456789:android:abcdef123456789',
        messagingSenderId: '123456789',
        projectId: 'riziko-development',
        storageBucket: 'riziko-development.appspot.com',
      );
    case TargetPlatform.iOS:
      return const FirebaseOptions(
        apiKey: 'AIzaSyDummyKeyForDevelopment',
        appId: '1:123456789:ios:abcdef123456789',
        messagingSenderId: '123456789',
        projectId: 'riziko-development',
        storageBucket: 'riziko-development.appspot.com',
      );
    default:
      return firebaseOptions;
  }
}
