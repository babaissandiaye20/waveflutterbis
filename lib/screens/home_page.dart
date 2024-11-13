import 'package:flutter/material.dart';
import 'widgets/header_widget.dart';
import 'widgets/qr_buttons.dart';
import 'widgets/action_buttons.dart';
import 'widgets/transactions_section.dart';
import 'widgets/transfer_modal/transfer_modal.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        child: const SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(),
              SizedBox(height: 20),
              QRButtons(),
              SizedBox(height: 20),
              ActionButtons(),
              SizedBox(height: 20),
              Expanded(child: TransactionsSection()),
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
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Transfert'),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Partager'),
        ],
      ),
    );
  }
}