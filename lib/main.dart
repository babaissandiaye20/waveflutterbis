// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'theme/zigfreak_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zigfreak Money',
      theme: ZigfreakTheme.theme, // Utilisation du thème personnalisé
      home: const WelcomePage(),
    );
  }
}
