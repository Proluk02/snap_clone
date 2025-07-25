import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authentification/login_page.dart';
import 'camera_page.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const SnapFeedPage(),
    const ChatPage(),
    const StoriesPage(),
    const MapPage(),
  ];

  void _seDeconnecter() async {
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
      extendBody: true,
      appBar:
          _currentIndex != 0
              ? null
              : AppBar(
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
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => _showSettings(context),
                    tooltip: 'Paramètres',
                  ),
                ],
              ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow[600],
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Stories'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCamera(context),
        backgroundColor: Colors.yellow[600],
        child: const Icon(Icons.camera_alt, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profil',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _seDeconnecter();
              },
            ),
          ],
        );
      },
    );
  }
}

// Pages supplémentaires (à créer dans des fichiers séparés)
class SnapFeedPage extends StatelessWidget {
  const SnapFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 150,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.yellow[800]!, Colors.red[800]!],
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.yellow[600],
                child: const Icon(Icons.person, color: Colors.black),
              ),
              title: Text(
                'Ami ${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Snap reçu il y a ${index + 1}h',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Icon(Icons.circle, color: Colors.yellow[600], size: 12),
              onTap: () {},
            ),
            childCount: 10,
          ),
        ),
      ],
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page Chat', style: TextStyle(color: Colors.white)),
    );
  }
}

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page Stories', style: TextStyle(color: Colors.white)),
    );
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page Carte', style: TextStyle(color: Colors.white)),
    );
  }
}
