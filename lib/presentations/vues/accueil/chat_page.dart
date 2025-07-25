import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Jean Dupont',
      'lastMessage': 'Salut, ça va ?',
      'time': '10:30',
      'unread': true,
      'avatar': 'J',
    },
    {
      'name': 'Marie Martin',
      'lastMessage': 'À demain !',
      'time': 'Hier',
      'unread': false,
      'avatar': 'M',
    },
    {
      'name': 'Pierre Lambert',
      'lastMessage': 'Regarde ce snap !',
      'time': 'Lundi',
      'unread': true,
      'avatar': 'P',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Chat', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.yellow[600],
              child: Text(
                chat['avatar'],
                style: const TextStyle(color: Colors.black),
              ),
            ),
            title: Text(
              chat['name'],
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    chat['unread'] ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              chat['lastMessage'],
              style: TextStyle(
                color: chat['unread'] ? Colors.yellow[600] : Colors.grey,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  chat['time'],
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (chat['unread'])
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.yellow[600],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            onTap: () => _openChat(chat),
          );
        },
      ),
    );
  }

  void _openChat(Map<String, dynamic> chat) {
    setState(() {
      chat['unread'] = false;
    });
    // Naviguer vers la page de conversation détaillée
  }
}
