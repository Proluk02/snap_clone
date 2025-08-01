import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap/screens/chat_screen.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("Contacter un utilisateur")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children:
                snapshot.data!.docs.map<Widget>((doc) {
                  Map<String, dynamic> data =
                      doc.data()! as Map<String, dynamic>;

                  // Ne pas s'afficher soi-même dans la liste
                  if (currentUser != null && currentUser.uid == data['uid']) {
                    return SizedBox.shrink();
                  }

                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['displayName'] ?? 'Utilisateur Anonyme'),
                    subtitle: Text(data['email'] ?? ''),
                    onTap: () {
                      // Naviguer vers l'écran de chat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatScreen(
                                receiverId: data['uid'],
                                receiverName:
                                    data['displayName'] ??
                                    'Utilisateur Anonyme',
                              ),
                        ),
                      );
                    },
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
