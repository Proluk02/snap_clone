import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var uuid = Uuid();

  // La liste des URL d'images est maintenant publique pour être utilisée par l'écran de sélection.
  final List<String> placeholderImageUrls = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
    'https://images.unsplash.com/photo-1511884642898-4c92249e20b6?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
    'https://images.unsplash.com/photo-1433086966358-54859d0ed716?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&w=3600',
  ];

  /// Publie une nouvelle story en utilisant une URL d'image spécifique.
  Future<String?> publishStory(String imageUrl) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("Erreur : Aucun utilisateur n'est connecté.");
        return null;
      }

      String storyId = uuid.v4();
      Timestamp now = Timestamp.now();
      Timestamp expiresAt = Timestamp.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch +
            (24 * 60 * 60 * 1000), // Expire dans 24 heures
      );

      await _firestore.collection('stories').doc(storyId).set({
        'storyId': storyId,
        'authorId': currentUser.uid,
        'mediaUrl': imageUrl, // Utilise l'URL passée en paramètre
        'mediaType': 'image', // Pour l'instant, seulement des images
        'timestamp': now,
        'expiresAt': expiresAt,
      });

      return "success";
    } catch (e) {
      print("Erreur lors de la publication de la story: $e");
      return null;
    }
  }

  /// Fournit un flux en temps réel des stories qui n'ont pas encore expiré.
  Stream<QuerySnapshot> getActiveStories() {
    return _firestore
        .collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt', descending: true)
        .snapshots();
  }

  Future<String?> publishTextStory(String text, Color backgroundColor) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      String storyId = uuid.v4();
      Timestamp now = Timestamp.now();
      Timestamp expiresAt = Timestamp.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch + (24 * 60 * 60 * 1000),
      );

      await _firestore.collection('stories').doc(storyId).set({
        'storyId': storyId,
        'authorId': currentUser.uid,
        'mediaType': 'text', // Le type est maintenant 'text'
        'text': text,
        'backgroundColor':
            backgroundColor.value
                .toString(), // On stocke la valeur int de la couleur
        'timestamp': now,
        'expiresAt': expiresAt,
        'mediaUrl': null, // Important de mettre à null
      });

      return "success";
    } catch (e) {
      print("Erreur lors de la publication de la story texte: $e");
      return null;
    }
  }
}
