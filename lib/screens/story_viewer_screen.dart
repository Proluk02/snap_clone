import 'package:flutter/material.dart';
import 'package:snap/models/story_model.dart';
import 'package:story_view/story_view.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final String authorName;

  const StoryViewerScreen({
    Key? key,
    required this.stories,
    required this.authorName,
  }) : super(key: key);

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  final StoryController controller = StoryController();
  final List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();
    // Configurer la langue pour timeago
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _buildStoryItems();
  }

  void _buildStoryItems() {
    for (var story in widget.stories) {
      if (story.mediaType == 'text' &&
          story.text != null &&
          story.backgroundColor != null) {
        storyItems.add(
          StoryItem.text(
            title: story.text!,
            backgroundColor: Color(int.parse(story.backgroundColor!)),
            textStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 8, color: Colors.black54),
              ], // Ombre pour la lisibilité
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else if (story.mediaType == 'image' && story.mediaUrl != null) {
        storyItems.add(
          StoryItem.pageImage(
            url: story.mediaUrl!,
            controller: controller,
            duration: const Duration(seconds: 5),
            // On retire le 'caption' d'ici car on gère l'affichage dans l'en-tête
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // La story affichée dans l'en-tête sera toujours la première de la liste
    final Story headerStory = widget.stories.first;

    return Scaffold(
      body: Stack(
        children: [
          // Couche 1 : Le visualiseur de story
          StoryView(
            storyItems: storyItems,
            controller: controller,
            onComplete: () => Navigator.pop(context),
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) Navigator.pop(context);
            },
            progressPosition: ProgressPosition.top,
            repeat: false,
            inline: false,
          ),

          // Couche 2 : L'en-tête de profil superposé
          _buildProfileHeader(headerStory),
        ],
      ),
    );
  }

  // Widget pour l'en-tête de profil
  Widget _buildProfileHeader(Story story) {
    return Positioned(
      top: 50, // Espace par rapport au haut de l'écran
      left: 16,
      right: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar de l'auteur
          CircleAvatar(
            radius: 20,
            backgroundImage:
                story.mediaType == 'image'
                    ? NetworkImage(story.mediaUrl!)
                    : null,
            child:
                story.mediaType == 'text'
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 12),
          // Nom et date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.authorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
                  ),
                ),
                Text(
                  timeago.format(
                    story.timestamp.toDate(),
                    locale: 'fr',
                  ), // Affiche "il y a 5 minutes"
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black87)],
                  ),
                ),
              ],
            ),
          ),
          // Bouton pour fermer
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
