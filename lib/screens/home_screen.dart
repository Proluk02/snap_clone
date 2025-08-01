import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:snap/models/story_model.dart';
import 'package:snap/services/auth_service.dart';
import 'package:snap/services/story_service.dart';
import 'package:snap/screens/story_viewer_screen.dart';
import 'package:snap/screens/image_selection_screen.dart';
import 'package:snap/screens/create_text_story_screen.dart';
import 'package:snap/screens/users_list_screen.dart';
import 'package:snap/utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _storyService = StoryService();

  // Variable d'état pour la couleur de fond dynamique et sa souscription
  Color _backgroundColor = AppConstants.backgroundColor;
  StreamSubscription? _storySubscription;

  @override
  void initState() {
    super.initState();
    _listenToStoriesForBackgroundUpdate();
  }

  /// Écoute les changements dans les stories pour mettre à jour la couleur de fond.
  void _listenToStoriesForBackgroundUpdate() {
    _storySubscription = _storyService.getActiveStories().listen((
      snapshot,
    ) async {
      if (snapshot.docs.isNotEmpty) {
        final firstStoryDoc = snapshot.docs.first;
        final firstStory = Story.fromSnap(firstStoryDoc);

        // Si la première story est une image, on tente d'extraire sa couleur
        if (firstStory.mediaType == 'image' && firstStory.mediaUrl != null) {
          _updateBackgroundColorFromImage(firstStory.mediaUrl!);
        } else {
          // Sinon, on remet la couleur par défaut
          if (mounted)
            setState(() => _backgroundColor = AppConstants.backgroundColor);
        }
      } else {
        // S'il n'y a plus de stories, on remet la couleur par défaut
        if (mounted)
          setState(() => _backgroundColor = AppConstants.backgroundColor);
      }
    });
  }

  /// Met à jour la couleur de fond en se basant sur une URL d'image.
  Future<void> _updateBackgroundColorFromImage(String imageUrl) async {
    try {
      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(
          100,
          100,
        ), // Analyse rapide sur une petite version de l'image
      );
      // On choisit la couleur "dominante" ou une couleur par défaut si l'analyse échoue
      final newColor =
          palette.dominantColor?.color ?? AppConstants.backgroundColor;
      if (mounted) setState(() => _backgroundColor = newColor);
    } catch (e) {
      // En cas d'erreur (image non trouvée, etc.), on revient à la couleur par défaut
      if (mounted)
        setState(() => _backgroundColor = AppConstants.backgroundColor);
    }
  }

  @override
  void dispose() {
    _storySubscription
        ?.cancel(); // Très important pour éviter les fuites de mémoire
    super.dispose();
  }

  /// Affiche un dialogue en bas de l'écran pour choisir le type de story à créer.
  Future<void> _showStoryTypeChoice() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardRadius),
        ),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Wrap(
                runSpacing: AppConstants.defaultPadding / 2,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Créer une Story",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.text_fields,
                      color: AppConstants.accentColor,
                    ),
                    title: const Text('Story Texte'),
                    onTap: () => Navigator.pop(context, 'text'),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.image_search,
                      color: AppConstants.accentColor,
                    ),
                    title: const Text('Story Image'),
                    onTap: () => Navigator.pop(context, 'image'),
                  ),
                ],
              ),
            ),
          ),
    );

    bool? publicationSuccess;
    if (result == 'text') {
      publicationSuccess = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateTextStoryScreen()),
      );
    } else if (result == 'image')
      // ignore: curly_braces_in_flow_control_structures
      publicationSuccess = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ImageSelectionScreen()),
      );

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

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeIn,
      color: _backgroundColor,
      child: Scaffold(
        backgroundColor:
            Colors
                .transparent, // Important pour voir la couleur de l'AnimatedContainer
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _storyService.getActiveStories(),
            builder: (context, snapshot) {
              // Affiche un indicateur de chargement seulement au premier lancement
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _backgroundColor == AppConstants.backgroundColor) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppConstants.primaryDark,
                  ),
                );
              }
              if (snapshot.hasError)
                return const Center(child: Text("Une erreur est survenue."));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return _buildEmptyState();

              List<Story> allStories =
                  snapshot.data!.docs
                      .map((doc) => Story.fromSnap(doc))
                      .toList();
              Map<String, List<Story>> groupedStories = {};
              for (var story in allStories) {
                groupedStories.putIfAbsent(story.authorId, () => []).add(story);
              }

              List<Story>? myStories = groupedStories.remove(currentUserId);
              Map<String, List<Story>> otherStories = groupedStories;

              return CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildStoriesList(myStories, otherStories),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showStoryTypeChoice,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 4.0,
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => CustomScrollView(
    slivers: [
      _buildHeader(),
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Center(
            child: Text(
              "Aucune story active.\nSoyez le premier !",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    ],
  );

  SliverToBoxAdapter _buildHeader() {
    bool isDefaultBg = _backgroundColor == AppConstants.backgroundColor;
    Color iconColor = isDefaultBg ? AppConstants.accentColor : Colors.white;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.defaultPadding / 2,
          20,
          AppConstants.defaultPadding,
          10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildActionButton(
                  Icons.person_outline,
                  () => _authService.signOut(),
                  isDefaultBg,
                  iconColor,
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/images/snap_logo.png',
                  height: 35,
                  color: iconColor,
                ),
              ],
            ),
            _buildActionButton(
              Icons.chat_bubble_outline,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UsersListScreen(),
                ),
              ),
              isDefaultBg,
              iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onPressed,
    bool isDefaultBg,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDefaultBg ? Colors.grey.shade200 : Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }

  SliverToBoxAdapter _buildStoriesList(
    List<Story>? myStories,
    Map<String, List<Story>> otherStories,
  ) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 125,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding / 2,
          ),
          itemCount: (myStories != null ? 1 : 0) + otherStories.length,
          itemBuilder: (context, index) {
            if (index == 0 && myStories != null)
              return _buildStoryBubble(
                stories: myStories,
                isMyStory: true,
                myName: _authService.currentUser?.displayName ?? "Moi",
              );
            final otherIndex = myStories != null ? index - 1 : index;
            String userId = otherStories.keys.elementAt(otherIndex);
            return _buildStoryBubble(
              stories: otherStories[userId]!,
              userId: userId,
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoryBubble({
    required List<Story> stories,
    String? userId,
    bool isMyStory = false,
    String? myName,
  }) {
    final firstImageStory = stories.firstWhere(
      (s) => s.mediaType == 'image',
      orElse: () => stories.first,
    );
    final isDefaultBg = _backgroundColor == AppConstants.backgroundColor;
    final textColor = isDefaultBg ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: () async {
        String authorName = "Utilisateur";
        if (isMyStory)
          authorName = myName ?? "Moi";
        else if (userId != null) {
          var userDetails = await _authService.getUserDetails(userId);
          if (mounted && userDetails.exists)
            authorName =
                (userDetails.data() as Map<String, dynamic>)['displayName'] ??
                'Anonyme';
        }
        if (mounted)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => StoryViewerScreen(
                    stories: stories,
                    authorName: authorName,
                  ),
            ),
          );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppConstants.headerGradient,
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      firstImageStory.mediaUrl != null
                          ? NetworkImage(firstImageStory.mediaUrl!)
                          : null,
                  child:
                      firstImageStory.mediaUrl == null
                          ? Icon(
                            isMyStory
                                ? Icons.add_circle_outline
                                : Icons.text_fields,
                            size: 30,
                            color: AppConstants.primaryDark,
                          )
                          : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            isMyStory
                ? Text(
                  "Ma Story",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                )
                : FutureBuilder<DocumentSnapshot>(
                  future: _authService.getUserDetails(userId!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox(height: 12);
                    String displayName =
                        (snapshot.data!.data()
                            as Map<String, dynamic>)['displayName'] ??
                        'Anonyme';
                    return Text(
                      displayName.split(' ').first,
                      style: TextStyle(fontSize: 13, color: textColor),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
