import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentations/vues/accueil/accueil_page.dart';
import 'presentations/vues/authentification/login_page.dart';
import 'presentations/vues/authentification/reset_password_page.dart';
import 'presentations/vues/authentification/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapClone',
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/reset': (_) => const ResetPasswordPage(),
        '/accueil': (_) => const AccueilPage(),
      },
    );
  }
}
