import 'package:flutter/material.dart';
import 'package:snap/models/story_model.dart';
import 'package:story_view/story_view.dart';

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
    _buildStoryItems();
  }

  void _buildStoryItems() {
    for (var story in widget.stories) {
      // Gérer le cas d'une story de type 'text'
      if (story.mediaType == 'text' &&
          story.text != null &&
          story.backgroundColor != null) {
        storyItems.add(
          StoryItem.text(
            title: story.text!,
            backgroundColor: Color(int.parse(story.backgroundColor!)),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      // Gérer le cas d'une story de type 'image'
      else if (story.mediaType == 'image' && story.mediaUrl != null) {
        storyItems.add(
          StoryItem.pageImage(
            url: story.mediaUrl!,
            controller: controller,
            caption: Text(
              "Posté par ${widget.authorName}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                backgroundColor:
                    Colors.black54, // Fond semi-transparent pour la lisibilité
              ),
            ),
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
    return Scaffold(
      body: StoryView(
        storyItems: storyItems,
        controller: controller,
        onComplete: () {
          Navigator.pop(context);
        },
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
        progressPosition: ProgressPosition.top,
        repeat: false,
        inline: false,
      ),
    );
  }
}
