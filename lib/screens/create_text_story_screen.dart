import 'package:flutter/material.dart';
import 'package:snap/services/story_service.dart';

class CreateTextStoryScreen extends StatefulWidget {
  const CreateTextStoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateTextStoryScreen> createState() => _CreateTextStoryScreenState();
}

class _CreateTextStoryScreenState extends State<CreateTextStoryScreen> {
  final _textController = TextEditingController();
  final _storyService = StoryService();
  bool _isPublishing = false;

  // Liste de couleurs de fond prédéfinies
  final List<Color> _backgroundColors = [
    Colors.blueGrey,
    Colors.indigo,
    Colors.teal,
    Colors.deepPurple,
    Colors.redAccent,
    Colors.orange,
  ];

  // Couleur actuellement sélectionnée
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _backgroundColors[0]; // Couleur par défaut
    // Met à jour l'aperçu quand le texte change
    _textController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _publish() async {
    if (_textController.text.trim().isEmpty || _isPublishing) return;

    setState(() {
      _isPublishing = true;
    });

    await _storyService.publishTextStory(
      _textController.text.trim(),
      _selectedColor,
    );

    if (mounted) {
      Navigator.pop(context, true); // Revenir à HomeScreen avec un succès
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Créer une story"),
        actions: [
          IconButton(
            icon:
                _isPublishing
                    ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                    : Icon(Icons.send),
            onPressed:
                _textController.text.trim().isEmpty || _isPublishing
                    ? null
                    : _publish,
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone d'aperçu
          Expanded(
            child: Container(
              color: _selectedColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    textAlign: TextAlign.center,
                    maxLines: null, // Permet plusieurs lignes
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "Écrivez quelque chose...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Palette de sélection de couleurs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  _backgroundColors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: color,
                        // Affiche une coche si c'est la couleur sélectionnée
                        child:
                            _selectedColor == color
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
