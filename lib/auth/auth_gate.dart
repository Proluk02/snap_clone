import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap/auth/login_or_signup.dart';
import 'package:snap/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginOrSignUp();
          }
        },
      ),
    );
  }
}
