import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool isReady = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
      isReady = true;
      debugPrint('Firebase initialized');
    } catch (e, st) {
      isReady = false;
      debugPrint('Firebase unavailable, using local seed assets: $e');
      debugPrint('$st');
    }
  }
}
