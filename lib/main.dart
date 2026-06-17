import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // You need the options block specifically for Chrome/Web testing!
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCOU_c_nhtsFKjzO_BmpqKPTX_O6cvFV2k",
        appId: "1:733722559391:web:40a6614071577257bfb3aa",
        messagingSenderId: "733722559391",
        projectId: "barakahhub-ef014",
        authDomain: "barakahhub-ef014.firebaseapp.com",
        storageBucket: "barakahhub-ef014.firebasestorage.app",
      ),
    );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
      ],
      child: MaterialApp(
        title: 'BarakahHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20), // A clean Islamic emerald green theme
          ),
        ),
        // Temporarily pointing to LoginScreen which we will build next
        home: const LoginScreen(), 
      ),
    );
  }
}