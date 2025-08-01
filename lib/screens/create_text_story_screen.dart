import 'package:flutter/material.dart';
import 'package:snap/services/story_service.dart';
import 'package:snap/utils/app_constants.dart';

class CreateTextStoryScreen extends StatefulWidget {
  const CreateTextStoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateTextStoryScreen> createState() => _CreateTextStoryScreenState();
}

class _CreateTextStoryScreenState extends State<CreateTextStoryScreen> {
  final _textController = TextEditingController();
  final _storyService = StoryService();
  bool _isPublishing = false;

  final List<Color> _backgroundColors = [
    const Color(0xFF6A1B9A), // Deep Purple
    const Color(0xFF1E88E5), // Blue
    const Color(0xFF00897B), // Teal
    const Color(0xFFC2185B), // Pink
    const Color(0xFFE64A19), // Deep Orange
    const Color(0xFF455A64), // Blue Grey
  ];
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _backgroundColors[0];
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_textController.text.trim().isEmpty || _isPublishing) return;
    setState(() => _isPublishing = true);
    await _storyService.publishTextStory(
      _textController.text.trim(),
      _selectedColor,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La couleur de fond change dynamiquement
      backgroundColor: _selectedColor,
      body: Stack(
        children: [
          // Zone de saisie de texte
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding * 2,
              ),
              child: TextField(
                controller: _textController,
                textAlign: TextAlign.center,
                maxLines: null,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black38)],
                ),
                decoration: const InputDecoration(
                  hintText: "Écrivez quelque chose...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // Boutons et palette de couleurs
          _buildOverlayControls(),
        ],
      ),
    );
  }

  Widget _buildOverlayControls() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Boutons du haut (Fermer)
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding / 2),
              child: FloatingActionButton.small(
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.black.withOpacity(0.4),
                child: const Icon(Icons.close),
              ),
            ),
          ),

          // Boutons du bas (Palette et Publier)
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildColorPalette(),
                FloatingActionButton.extended(
                  onPressed:
                      _textController.text.trim().isEmpty || _isPublishing
                          ? null
                          : _publish,
                  backgroundColor:
                      _textController.text.trim().isNotEmpty
                          ? Colors.white
                          : Colors.grey.shade400,
                  foregroundColor: Colors.black,
                  icon: _isPublishing ? null : const Icon(Icons.send),
                  label:
                      _isPublishing
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text("Publier"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            _backgroundColors.map((color) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border:
                        _selectedColor == color
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
