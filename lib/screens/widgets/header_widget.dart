// widgets/header_widget.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  bool _isBalanceVisible = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _compteInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCompteInfo();
  }
   void refreshBalance() {
    setState(() => _isLoading = true);
    _fetchCompteInfo();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        setState(() {
          _userData = json.decode(userDataString);
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  Future<void> _fetchCompteInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.25:8000/api/compte-info'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _compteInfo = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des informations du compte: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getUserName() {
    if (_userData != null) {
      final prenom = _userData?['prenom'] ?? '';
      final nom = _userData?['nom'] ?? '';
      return '$prenom $nom'.trim();
    }
    return 'Utilisateur';
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0';
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final solde = _compteInfo?['solde'] ?? 0;
    final formattedSolde = _formatAmount(solde);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bonjour, ${_getUserName()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                _isBalanceVisible ? '$formattedSolde FCFA' : '••••••',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                child: Icon(
                  _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}