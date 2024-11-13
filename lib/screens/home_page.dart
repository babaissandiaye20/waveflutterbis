import 'package:flutter/material.dart';
import 'widgets/header_widget.dart';
import 'widgets/qr_buttons.dart';
import 'widgets/action_buttons.dart';
import 'widgets/transactions_section.dart';
import 'package:waveflutter/services/interfaces/IHttpClient.dart';
import 'package:waveflutter/services/ApiService.dart';
import 'package:waveflutter/services/HttpClient.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final httpClient = HttpClient(); // Utilisez l'implémentation concrète
    final apiService =ApiService(httpClient); // Passez une instance de IHttpClient

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD700),
              Color(0xFFDAA520),
              Color(0xFF4A4A4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(),
              const SizedBox(height: 20),
              const QRButtons(),
              const SizedBox(height: 20),
              ActionButtons(httpClient: httpClient), // Passez httpClient ici
              const SizedBox(height: 20),
              const Expanded(child: TransactionsSection()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black87,
        selectedItemColor: const Color(0xFF6750A4), // Couleur secondaire
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Transfert'),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Partager'),
        ],
      ),
    );
  }
}
