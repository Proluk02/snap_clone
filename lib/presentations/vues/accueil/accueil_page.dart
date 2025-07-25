import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authentification/login_page.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  void _seDeconnecter(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder:
            (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Snapclone',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _seDeconnecter(context),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar et pseudo/email
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.yellow[600],
              child: const Icon(Icons.person, color: Colors.black),
            ),
            title: Text(
              user?.email ?? "utilisateur",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "Connecté à Snapclone",
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Icon(Icons.verified_user, color: Colors.green[400]),
          ),

          const SizedBox(height: 20),

          // Snap content vide (mockup feed)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 60,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aucun snap pour le moment",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fonction caméra non disponible pour le moment'),
              backgroundColor: Colors.grey,
            ),
          );
        },
        backgroundColor: Colors.yellow[600],
        child: const Icon(Icons.camera_alt, color: Colors.black),
      ),
    );
  }
}
