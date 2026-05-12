// Config générée à partir du projet Firebase « eskolia » (CLI + console).
// Pour régénérer : flutterfire configure --project=eskolia

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
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ne gère pas cette plateforme.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlIQgCGaeirNFGEvHaaMg8TGkFy6FxTJ8',
    appId: '1:906063398055:web:ce8b673bfcf82c29c98782',
    messagingSenderId: '906063398055',
    projectId: 'eskolia',
    authDomain: 'eskolia.firebaseapp.com',
    storageBucket: 'eskolia.firebasestorage.app',
    measurementId: 'G-9QYFT9Q2V6',
    databaseURL: 'https://eskolia-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAycs9o94i0yBiVEVHQof7wiJ-ukMHuTKE',
    appId: '1:906063398055:android:57d00322929fbaffc98782',
    messagingSenderId: '906063398055',
    projectId: 'eskolia',
    storageBucket: 'eskolia.firebasestorage.app',
    databaseURL: 'https://eskolia-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1SPQrpUekd3xoQhEYmfMMMa0r-XdutMM',
    appId: '1:906063398055:ios:ed52ba75ef9d8272c98782',
    messagingSenderId: '906063398055',
    projectId: 'eskolia',
    storageBucket: 'eskolia.firebasestorage.app',
    iosBundleId: 'com.eskolia.app.eskolia',
    databaseURL: 'https://eskolia-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB1SPQrpUekd3xoQhEYmfMMMa0r-XdutMM',
    appId: '1:906063398055:ios:ed52ba75ef9d8272c98782',
    messagingSenderId: '906063398055',
    projectId: 'eskolia',
    storageBucket: 'eskolia.firebasestorage.app',
    iosBundleId: 'com.eskolia.app.eskolia',
    databaseURL: 'https://eskolia-default-rtdb.europe-west1.firebasedatabase.app',
  );
}
