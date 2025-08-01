import 'package:flutter/material.dart';
import 'package:snap/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const SignUpScreen({Key? key, required this.showLoginScreen})
    : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // AJOUTER UN CONTRÔLEUR POUR LE NOM
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose(); // Ne pas oublier de le libérer
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AJOUTER UN CHAMP DE TEXTE POUR LE NOM
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom complet'),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe (6+ caractères)',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => _authService.signUpWithEmail(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _nameController.text.trim(),
                  ),
              child: Text("S'inscrire"),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: widget.showLoginScreen,
              child: Text("Déjà un compte ? Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
