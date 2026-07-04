import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

// Default Firebase configuration (Android values, project riziko-72c8f).
// iOS and web are not yet registered with this Firebase project — running
// on those platforms will need `flutterfire configure` to add them.
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyBlLE2HXMzt3vKJ_Y0xmIRDgfmByUFrmhc',
  appId: '1:597482279851:android:d306df64a79c8d34d5f8ee',
  messagingSenderId: '597482279851',
  projectId: 'riziko-72c8f',
  storageBucket: 'riziko-72c8f.firebasestorage.app',
  databaseURL: 'https://riziko-72c8f-default-rtdb.europe-west1.firebasedatabase.app',
);

// Platform-specific configuration
FirebaseOptions get currentPlatform {
  if (kIsWeb) {
    return firebaseOptions;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return firebaseOptions;
    case TargetPlatform.iOS:
      return firebaseOptions;
    default:
      return firebaseOptions;
  }
}
