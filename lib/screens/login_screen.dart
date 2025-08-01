import 'package:flutter/material.dart';
import 'package:snap/services/auth_service.dart';
import 'package:snap/utils/app_constants.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signIn() async {
    // Valider le formulaire avant de continuer
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
    final user = await _authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email ou mot de passe incorrect."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // --- L'EN-TÊTE AVEC DÉGRADÉ ---
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: AppConstants.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          // --- CONTENU PRINCIPAL ---
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // --- LOGO ---
                  Image.asset('assets/images/snap_logo.png', height: 80),
                  const SizedBox(height: 20),

                  // --- CARTE FLOTTANTE ---
                  _buildAuthCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour la carte d'authentification
  Widget _buildAuthCard() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "CONNEXION",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.accentColor,
                  ),
                ),
                const SizedBox(height: 30),
                _buildModernTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                _buildModernTextField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 30),
                _buildModernAuthButton(
                  text: 'Se connecter',
                  onPressed: _signIn,
                ),
                const SizedBox(height: 20),
                _buildSwitchAuthLink(
                  "Pas encore de compte ?",
                  " S'inscrire",
                  widget.showSignUpScreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour les champs de texte
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          (value) =>
              value == null || value.trim().isEmpty ? 'Champ requis' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primaryDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(
            color: AppConstants.primaryDark,
            width: 2,
          ),
        ),
      ),
    );
  }

  // Widget pour le bouton principal
  Widget _buildModernAuthButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppConstants.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  // Widget pour le lien de bascule (Connexion/Inscription)
  Widget _buildSwitchAuthLink(
    String text1,
    String text2,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black54),
          children: [
            TextSpan(text: text1),
            TextSpan(
              text: text2,
              style: const TextStyle(
                color: AppConstants.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
