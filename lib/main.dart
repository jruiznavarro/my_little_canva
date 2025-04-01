import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_little_canva/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD60kCn87nmdJcBW_PGntRXMymWOaxAr0U",
        authDomain: "my-little-canva.firebaseapp.com",
        projectId: "my-little-canva",
        storageBucket: "my-little-canva.appspot.com",
        messagingSenderId: "272425255050",
        appId: "1:272425255050:web:fff8cbd2a0eea40f77ed73",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'My Little Canva',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4285F4)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
