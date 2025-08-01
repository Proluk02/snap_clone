import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String storyId;
  final String authorId;
  final String mediaType;
  final Timestamp timestamp;

  final String? mediaUrl;
  final String? text;
  final String? backgroundColor;

  Story({
    required this.storyId,
    required this.authorId,
    required this.mediaType,
    required this.timestamp,
    this.mediaUrl,
    this.text,
    this.backgroundColor,
  });

  factory Story.fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Story(
      storyId: data['storyId'],
      authorId: data['authorId'],
      mediaType: data['mediaType'],
      timestamp: data['timestamp'],
      mediaUrl: data['mediaUrl'],
      text: data['text'],
      backgroundColor: data['backgroundColor'],
    );
  }
}
