import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snap/models/story_model.dart';
import 'package:snap/services/auth_service.dart';
import 'package:snap/services/story_service.dart';
import 'package:snap/screens/story_viewer_screen.dart';
import 'package:snap/screens/image_selection_screen.dart';
import 'package:snap/screens/create_text_story_screen.dart';
import 'package:snap/screens/users_list_screen.dart'; // Import pour accéder à la liste des utilisateurs

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _storyService = StoryService();

  /// Affiche un dialogue en bas de l'écran pour choisir le type de story à créer.
  Future<void> _showStoryTypeChoice() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Story Texte'),
                onTap: () => Navigator.pop(context, 'text'),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Story Image'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
            ],
          ),
        );
      },
    );

    // Gère la navigation en fonction du choix de l'utilisateur
    bool? publicationSuccess;
    if (result == 'text') {
      publicationSuccess = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateTextStoryScreen()),
      );
    } else if (result == 'image') {
      publicationSuccess = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ImageSelectionScreen()),
      );
    }

    // Affiche un message de confirmation si une story a bien été publiée
    if (publicationSuccess == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Story publiée !"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stories"),
        actions: [
          // BOUTON POUR ACCÉDER AU CHAT
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: "Ouvrir le chat",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UsersListScreen(),
                ),
              );
            },
          ),
          // BOUTON DE DÉCONNEXION
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Se déconnecter",
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _storyService.getActiveStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Une erreur est survenue."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aucune story active. Soyez le premier !"),
            );
          }

          // Logique de tri pour séparer "My Story" des autres
          List<Story> allStories =
              snapshot.data!.docs.map((doc) => Story.fromSnap(doc)).toList();
          Map<String, List<Story>> groupedStories = {};
          for (var story in allStories) {
            groupedStories.putIfAbsent(story.authorId, () => []).add(story);
          }

          List<Story>? myStories = groupedStories.remove(currentUserId);
          Map<String, List<Story>> otherStories = groupedStories;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section pour la story de l'utilisateur connecté
              if (myStories != null)
                Builder(
                  builder: (context) {
                    final firstImageStory = myStories.firstWhere(
                      (s) => s.mediaType == 'image',
                      orElse: () => myStories.first,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.green,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              firstImageStory.mediaUrl != null
                                  ? NetworkImage(firstImageStory.mediaUrl!)
                                  : null,
                          child:
                              firstImageStory.mediaUrl == null
                                  ? const Icon(
                                    Icons.text_fields,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                      title: const Text(
                        "My Story",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${myStories.length} publication${myStories.length > 1 ? 's' : ''}",
                      ),
                      onTap: () {
                        final myName =
                            _authService.currentUser?.displayName ?? "Moi";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StoryViewerScreen(
                                  stories: myStories,
                                  authorName: myName,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),

              // Séparateur pour les autres stories
              if (otherStories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    "Mises à jour récentes",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ),

              // Liste des stories des autres utilisateurs
              Expanded(
                child: ListView.builder(
                  itemCount: otherStories.length,
                  itemBuilder: (context, index) {
                    String userId = otherStories.keys.elementAt(index);
                    List<Story> userStories = otherStories[userId]!;

                    return FutureBuilder<DocumentSnapshot>(
                      future: _authService.getUserDetails(userId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return const SizedBox.shrink();
                        }

                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        String displayName =
                            userData['displayName'] ?? 'Utilisateur Anonyme';

                        final firstImageStory = userStories.firstWhere(
                          (s) => s.mediaType == 'image',
                          orElse: () => userStories.first,
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blueAccent,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  firstImageStory.mediaUrl != null
                                      ? NetworkImage(firstImageStory.mediaUrl!)
                                      : null,
                              child:
                                  firstImageStory.mediaUrl == null
                                      ? const Icon(
                                        Icons.text_fields,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                          title: Text(displayName),
                          subtitle: Text(
                            "${userStories.length} publication${userStories.length > 1 ? 's' : ''}",
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => StoryViewerScreen(
                                      stories: userStories,
                                      authorName: displayName,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showStoryTypeChoice,
        child: const Icon(Icons.add),
      ),
    );
  }
}
