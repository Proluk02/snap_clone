import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap/models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Récupère le flux de messages pour une conversation donnée.
  Stream<QuerySnapshot> getMessages(String receiverId) {
    // Construire l'ID de la salle de chat
    List<String> ids = [_auth.currentUser!.uid, receiverId];
    ids.sort(); // Assure la consistance de l'ID
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Les plus anciens en premier
        .snapshots();
  }

  /// Envoie un nouveau message.
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // Créer le nouveau message
    ChatMessage newMessage = ChatMessage(
      senderId: currentUserId,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Construire l'ID de la salle de chat
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Ajouter le message à la sous-collection 'messages'
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    // Mettre à jour les métadonnées de la salle de chat (pour les aperçus futurs)
    await _firestore.collection('chat_rooms').doc(chatRoomId).set(
      {'users': ids, 'lastMessage': message, 'lastMessageTimestamp': timestamp},
      SetOptions(merge: true),
    ); // 'merge: true' pour ne pas écraser les champs existants
  }
}
