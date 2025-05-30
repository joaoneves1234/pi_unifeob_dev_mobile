// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDf95k-FIutKj-rRksWxR5M79mpHFiW6gw',
    appId: '1:831169649859:web:e03b72a00163eb492a5676',
    messagingSenderId: '831169649859',
    projectId: 'pi-unifeob',
    authDomain: 'pi-unifeob.firebaseapp.com',
    storageBucket: 'pi-unifeob.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_A9tfoEviRokwqgsooVcZvVeSmTF2J4o',
    appId: '1:831169649859:android:4cad341c1a8356772a5676',
    messagingSenderId: '831169649859',
    projectId: 'pi-unifeob',
    storageBucket: 'pi-unifeob.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5z5I6jct9p0FjS_4cvLGrk-O8matyWMs',
    appId: '1:831169649859:ios:eba525455395f1292a5676',
    messagingSenderId: '831169649859',
    projectId: 'pi-unifeob',
    storageBucket: 'pi-unifeob.firebasestorage.app',
    iosClientId: '831169649859-h9s2v3mj86ol35run3t2o337b7rcmrdm.apps.googleusercontent.com',
    iosBundleId: 'com.example.testeProjeto',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5z5I6jct9p0FjS_4cvLGrk-O8matyWMs',
    appId: '1:831169649859:ios:eba525455395f1292a5676',
    messagingSenderId: '831169649859',
    projectId: 'pi-unifeob',
    storageBucket: 'pi-unifeob.firebasestorage.app',
    iosClientId: '831169649859-h9s2v3mj86ol35run3t2o337b7rcmrdm.apps.googleusercontent.com',
    iosBundleId: 'com.example.testeProjeto',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDf95k-FIutKj-rRksWxR5M79mpHFiW6gw',
    appId: '1:831169649859:web:38e546d25bf307ce2a5676',
    messagingSenderId: '831169649859',
    projectId: 'pi-unifeob',
    authDomain: 'pi-unifeob.firebaseapp.com',
    storageBucket: 'pi-unifeob.firebasestorage.app',
  );

}