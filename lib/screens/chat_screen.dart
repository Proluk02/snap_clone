import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snap/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final _currentUser = FirebaseAuth.instance.currentUser!;

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      // Stocker le message avant de vider le contrôleur
      String messageToSend = _messageController.text.trim();

      // Vider le champ de texte immédiatement pour une meilleure expérience utilisateur
      _messageController.clear();

      // Envoyer le message en arrière-plan
      await _chatService.sendMessage(widget.receiverId, messageToSend);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          // Section pour afficher les messages
          Expanded(child: _buildMessagesList()),
          // Section pour envoyer un message
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget pour la liste des messages
  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Erreur de chargement des messages."));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Widget pour un seul message (une bulle de chat)
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Déterminer si le message est de l'utilisateur connecté ou du destinataire
    bool isSender = data['senderId'] == _currentUser.uid;

    // Aligner la bulle à droite si c'est l'expéditeur, à gauche sinon
    var alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSender ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isSender ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isSender ? Radius.circular(0) : Radius.circular(12),
          ),
        ),
        child: Text(
          data['message'],
          style: TextStyle(color: isSender ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // Widget pour le champ de saisie et le bouton d'envoi
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Écrire un message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
