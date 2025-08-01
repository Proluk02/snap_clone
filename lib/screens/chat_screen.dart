import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snap/services/chat_service.dart';
import 'package:snap/utils/app_constants.dart';

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
      String messageToSend = _messageController.text.trim();
      _messageController.clear();
      await _chatService.sendMessage(widget.receiverId, messageToSend);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.chatBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppConstants.receiverBubbleColor,
              child: Text(
                widget.receiverName[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.receiverName,
              style: const TextStyle(
                color: AppConstants.chatPrimaryTextColor, // CORRIGÉ
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.chatBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppConstants.chatPrimaryTextColor,
        ), // CORRIGÉ
      ),
      body: Column(
        children: [Expanded(child: _buildMessagesList()), _buildMessageInput()],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Erreur..."));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox());
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding / 2,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isSender = data['senderId'] == _currentUser.uid;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSender
                  ? AppConstants.senderBubbleColor
                  : AppConstants.receiverBubbleColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          data['message'],
          style: const TextStyle(
            fontSize: 16,
            color: AppConstants.chatPrimaryTextColor, // CORRIGÉ
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding / 2),
        child: Container(
          decoration: BoxDecoration(
            color: AppConstants.inputBackgroundColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.camera_alt,
                  color: AppConstants.chatIconColor, // CORRIGÉ
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(
                    color: AppConstants.chatPrimaryTextColor,
                  ), // CORRIGÉ
                  decoration: const InputDecoration(
                    hintText: "Envoyer un chat...",
                    hintStyle: TextStyle(
                      color: AppConstants.chatSecondaryTextColor, // CORRIGÉ
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send,
                  color: AppConstants.chatIconColor,
                ), // CORRIGÉ
              ),
            ],
          ),
        ),
      ),
    );
  }
}
