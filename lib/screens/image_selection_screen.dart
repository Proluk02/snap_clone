import 'package:flutter/material.dart';
import 'package:snap/services/story_service.dart';
import 'package:snap/utils/app_constants.dart';

class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  final _storyService = StoryService();
  String? _selectedImageUrl;
  bool _isPublishing = false;

  Future<void> _publishStory() async {
    if (_selectedImageUrl == null || _isPublishing) return;
    setState(() => _isPublishing = true);
    await _storyService.publishStory(_selectedImageUrl!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      // On utilise un Stack pour superposer les boutons d'action
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Titre de l'écran
                const Padding(
                  padding: EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text(
                    "Choisir une image",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // Grille d'images
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding / 2,
                    ),
                    itemCount: _storyService.placeholderImageUrls.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              3, // 3 images par ligne pour plus de choix
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                    itemBuilder: (context, index) {
                      final imageUrl =
                          _storyService.placeholderImageUrls[index];
                      final isSelected = imageUrl == _selectedImageUrl;
                      return _buildImageTile(imageUrl, isSelected);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Boutons d'action flottants
          _buildActionButtons(),
        ],
      ),
    );
  }

  // Widget pour une tuile d'image
  Widget _buildImageTile(String imageUrl, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedImageUrl = imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder:
                  (context, child, p) =>
                      p == null
                          ? child
                          : const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: AppConstants.primaryDark.withOpacity(0.6),
                  border: Border.all(
                    color: AppConstants.primaryColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
          ],
        ),
      ),
    );
  }

  // Widget pour les boutons flottants
  Widget _buildActionButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton fermer
            FloatingActionButton.small(
              heroTag: 'close_button',
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.black.withOpacity(0.4),
              child: const Icon(Icons.close),
            ),
            // Bouton Publier
            FloatingActionButton.extended(
              heroTag: 'publish_button',
              onPressed:
                  _selectedImageUrl == null || _isPublishing
                      ? null
                      : _publishStory,
              backgroundColor:
                  _selectedImageUrl != null
                      ? AppConstants.primaryDark
                      : Colors.grey,
              icon: _isPublishing ? null : const Icon(Icons.send),
              label:
                  _isPublishing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text("Publier"),
            ),
          ],
        ),
      ),
    );
  }
}
