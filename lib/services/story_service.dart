import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var uuid = Uuid();

  // LISTE DÉFINITIVE D'IMAGES STABLES PROVENANT DE PEXELS
  final List<String> placeholderImageUrls = [
    // Paysages
    'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/3244513/pexels-photo-3244513.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/167699/pexels-photo-167699.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.unsplash.com/photo-1753903770752-2958349862f5?q=80&w=1936&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
        // Villes et Architecture
        'https://images.pexels.com/photos/2246476/pexels-photo-2246476.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/210307/pexels-photo-210307.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/208701/pexels-photo-208701.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',

    // Personnes et Portraits
    'https://plus.unsplash.com/premium_photo-1753211477530-ac7d65a3119f?q=80&w=1990&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
        'https://images.pexels.com/photos/1310522/pexels-photo-1310522.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/837358/pexels-photo-837358.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/846741/pexels-photo-846741.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',

    // Animaux
    'https://images.pexels.com/photos/47547/squirrel-animal-cute-rodents-47547.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/3498323/pexels-photo-3498323.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',

    // Abstrait et Textures
    'https://images.pexels.com/photos/2110951/pexels-photo-2110951.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.unsplash.com/photo-1753696053910-1166f7c6751e?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
        // Objets et Divers
        'https://images.pexels.com/photos/356079/pexels-photo-356079.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/129733/pexels-photo-129733.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'https://images.pexels.com/photos/38554/girl-people-landscape-sun-38554.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  ];

  /// Publie une nouvelle story de type 'image'
  Future<String?> publishStory(String imageUrl) async {
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
        'mediaUrl': imageUrl,
        'mediaType': 'image',
        'text': null,
        'backgroundColor': null,
        'timestamp': now,
        'expiresAt': expiresAt,
      });

      return "success";
    } catch (e) {
      print("Erreur lors de la publication de la story image: $e");
      return null;
    }
  }

  /// Publie une nouvelle story de type 'texte'
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
        'mediaUrl': null,
        'mediaType': 'text',
        'text': text,
        'backgroundColor': backgroundColor.value.toString(),
        'timestamp': now,
        'expiresAt': expiresAt,
      });

      return "success";
    } catch (e) {
      print("Erreur lors de la publication de la story texte: $e");
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
}
