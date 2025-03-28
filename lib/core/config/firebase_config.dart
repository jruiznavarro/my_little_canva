import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> init() async {
    try {
      if (kIsWeb) {
        // Configuración para Web
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyD60kCn87nmdJcBW_PGntRXMymWOaxAr0U",
            authDomain: "my-little-canva.firebaseapp.com",
            projectId: "my-little-canva",
            storageBucket: "my-little-canva.appspot.com",
            messagingSenderId: "272425255050",
            appId: "1:272425255050:web:fff8cbd2a0eea40f77ed73"
          ),
        );
      } else {
        // Configuración para Android/iOS
        await Firebase.initializeApp();
      }
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }
} 