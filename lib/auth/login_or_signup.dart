import 'package:flutter/material.dart';
import 'package:snap/screens/login_screen.dart';
import 'package:snap/screens/signup_screen.dart';

class LoginOrSignUp extends StatefulWidget {
  const LoginOrSignUp({Key? key}) : super(key: key);

  @override
  State<LoginOrSignUp> createState() => _LoginOrSignUpState();
}

class _LoginOrSignUpState extends State<LoginOrSignUp> {
  // Par défaut, on montre la page de connexion
  bool showLoginPage = true;

  // Méthode pour basculer entre les deux pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(showSignUpScreen: togglePages);
    } else {
      return SignUpScreen(showLoginScreen: togglePages);
    }
  }
}
