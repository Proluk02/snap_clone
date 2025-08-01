import 'package:flutter/material.dart';
import 'package:snap/services/story_service.dart';

// Étape 1: Convertir en StatefulWidget pour gérer l'état de la sélection
class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final _storyService = StoryService();

  // Variable d'état pour garder en mémoire l'URL de l'image sélectionnée
  String? _selectedImageUrl;
  bool _isPublishing = false;

  // Méthode pour gérer la publication
  Future<void> _publishStory() async {
    // Sécurité: ne rien faire si aucune image n'est sélectionnée ou si une publication est déjà en cours
    if (_selectedImageUrl == null || _isPublishing) return;

    setState(() {
      _isPublishing = true; // Démarre l'indicateur de chargement
    });

    await _storyService.publishStory(_selectedImageUrl!);

    // Si le widget est toujours monté, on ferme l'écran avec un signal de succès
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choisir une image"),
        actions: [
          // Étape 4: Le bouton de confirmation
          // Il est désactivé si aucune image n'est sélectionnée ou si on publie déjà
          IconButton(
            icon:
                _isPublishing
                    ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                    : Icon(Icons.check),
            onPressed:
                _selectedImageUrl == null || _isPublishing
                    ? null
                    : _publishStory,
            tooltip: "Publier la story",
          ),
        ],
      ),
      // Étape 2: GridView.builder est la bonne approche pour afficher une liste
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _storyService.placeholderImageUrls.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 images par ligne
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          final imageUrl = _storyService.placeholderImageUrls[index];
          final isSelected =
              imageUrl ==
              _selectedImageUrl; // Vérifie si cette image est celle sélectionnée

          // Étape 3: Gérer la sélection et l'affichage stylé
          return GestureDetector(
            onTap: () {
              // Met à jour l'état pour indiquer quelle image est maintenant sélectionnée
              setState(() {
                _selectedImageUrl = imageUrl;
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              // On utilise un Stack pour superposer l'image, un voile de couleur et une icône
              child: Stack(
                fit:
                    StackFit
                        .expand, // Fait en sorte que les enfants remplissent tout l'espace
                children: [
                  // L'image de fond
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (context, child, progress) =>
                            progress == null
                                ? child
                                : Center(child: CircularProgressIndicator()),
                  ),

                  // Si l'image est sélectionnée, on ajoute les décorations
                  if (isSelected) ...[
                    // Un voile sombre pour faire ressortir l'icône
                    Container(color: Colors.black.withOpacity(0.5)),
                    // L'icône de coche au centre
                    Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
