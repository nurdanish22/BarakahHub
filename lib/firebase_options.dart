import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCOU_c_nhtsFKjzO_BmpqKPTX_O6cvFV2k",
    appId: "1:733722559391:web:40a6614071577257bfb3aa",
    messagingSenderId: "733722559391",
    projectId: "barakahhub-ef014",
    authDomain: "barakahhub-ef014.firebaseapp.com",
    storageBucket: "barakahhub-ef014.firebasestorage.app",
    measurementId: "G-CBKGQQZ9FL"
  );
}