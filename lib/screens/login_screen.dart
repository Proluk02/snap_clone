import 'package:flutter/material.dart';
import 'package:snap/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback showSignUpScreen;
  const LoginScreen({Key? key, required this.showSignUpScreen})
    : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => _authService.signInWithEmail(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  ),
              child: Text('Se connecter'),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: widget.showSignUpScreen,
              child: Text("Pas encore de compte ? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
