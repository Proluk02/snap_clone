import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap/screens/chat_screen.dart';
import 'package:snap/utils/app_constants.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppConstants.chatBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Nouveau Chat",
          style: TextStyle(color: AppConstants.chatPrimaryTextColor), // CORRIGÉ
        ),
        backgroundColor: AppConstants.chatBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppConstants.chatPrimaryTextColor,
        ), // CORRIGÉ
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erreur'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data()! as Map<String, dynamic>;

              if (currentUser != null && currentUser.uid == data['uid']) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppConstants.senderBubbleColor,
                  child: Text(
                    data['displayName']?[0] ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  data['displayName'] ?? 'Anonyme',
                  style: const TextStyle(
                    color: AppConstants.chatPrimaryTextColor, // CORRIGÉ
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Appuyer pour discuter",
                  style: TextStyle(
                    color: AppConstants.chatSecondaryTextColor, // CORRIGÉ
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            receiverId: data['uid'],
                            receiverName: data['displayName'] ?? 'Anonyme',
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
