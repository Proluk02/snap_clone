import 'package:flutter/material.dart';

class AppConstants {
  // --- COULEURS THÈME PRINCIPAL (JAUNE) ---
  static const Color primaryColor = Color(0xFFFFFC00);
  static const Color primaryDark = Color(0xFFFBC02D);
  static const Color accentColor = Color(0xFF4A4A4A);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static const Gradient headerGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- COULEURS THÈME CHAT (SOMBRE) ---
  static const Color chatBackgroundColor = Color(0xFF1E1E1E);
  static const Color senderBubbleColor = Color(0xFF007AFF);
  static const Color receiverBubbleColor = Color(0xFF3E3E3E);
  static const Color inputBackgroundColor = Color(0xFF2E2E2E);

  // --- COULEURS DE TEXTE ET D'ICÔNES (LES LIGNES MANQUANTES) ---
  // On utilise un préfixe "chat" pour les couleurs du thème sombre pour éviter les confusions
  static const Color chatPrimaryTextColor = Colors.white;
  static const Color chatSecondaryTextColor = Colors.white70;
  static const Color chatIconColor = Colors.white;

  // --- ESPACEMENTS ET RAYONS (UNIFIÉS) ---
  static const double defaultPadding = 20.0;
  static const double cardRadius = 25.0;
  static const double inputRadius = 15.0;
}
