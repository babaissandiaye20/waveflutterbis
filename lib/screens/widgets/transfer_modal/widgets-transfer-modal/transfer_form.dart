import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:waveflutter/models/contact.dart';

class TransferForm extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController motifController;
  final bool paysFees;
  final ValueChanged<bool> togglePaysFees;
  final String token;

  const TransferForm({
    Key? key,
    required this.amountController,
    required this.motifController,
    required this.paysFees,
    required this.togglePaysFees,
    required this.token,
  }) : super(key: key);

  static Future<void> performTransfer(
    bool isScheduled,
    List<Contact> contacts,
    String amount,
    String motif,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String selectedFrequency,
    bool paysFees,
    String token,
    Function onAuthError,
    Function updateBalance,
    Function(String) onError,
    Function(String) onSuccess,
  ) async {
    if (!_validateTransfer(amount, contacts)) {
      onError('Veuillez vérifier les données du transfert');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = await _getUserData(prefs);
      if (userData == null) {
        onError('Impossible de récupérer les données utilisateur');
        onAuthError();
        return;
      }

      // Récupérer le token stocké
      final storedToken = await _getStoredToken();
      if (storedToken == null || storedToken.isEmpty) {
        onError('Session expirée. Veuillez vous reconnecter.');
        onAuthError();
        return;
      }

      final selectedContacts = contacts.where((c) => c.isSelected && c.exists).toList();
      
      final Map<String, dynamic> transferData = {
        'sender_id': userData['id'],
        'type_transaction_id': 1,
        'montant': double.parse(amount),
        'receiver_phones': selectedContacts.map((c) => c.phoneNumber).toList(),
        'motif': motif,
        'frais': paysFees,
      };

      if (isScheduled && selectedDate != null && selectedTime != null) {
        final dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        
        transferData.addAll({
          'date_planification': dateTime.toIso8601String(),
          'frequence': selectedFrequency,
        });
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.25:8000/api/transactions'),
        headers: {
          'Authorization': storedToken.startsWith('Bearer ') ? storedToken : 'Bearer $storedToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode(transferData),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 401) {
        onError('Session expirée. Veuillez vous reconnecter.');
        onAuthError();
        return;
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          onSuccess(responseData['message'] ?? 'Transfert effectué avec succès');
          updateBalance();
        } else {
          onError(responseData['message'] ?? 'Une erreur est survenue');
        }
      } else {
        _handleErrorResponse(response, onError);
      }
    } catch (e) {
      onError('Erreur lors du transfert: ${e.toString()}');
    }
  }

  // Nouvelle méthode pour récupérer le token stocké
  static Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static void _handleErrorResponse(http.Response response, Function(String) onError) {
    try {
      final responseData = json.decode(response.body);
      final message = responseData['message'] ?? 
                     responseData['error'] ?? 
                     'Erreur ${response.statusCode}';
      onError(message);
    } catch (e) {
      onError('Erreur inattendue: ${response.statusCode}');
    }
  }

  static bool _validateTransfer(String amount, List<Contact> contacts) {
    if (amount.isEmpty) return false;
    
    try {
      final double parsedAmount = double.parse(amount);
      if (parsedAmount <= 0) return false;
    } catch (e) {
      return false;
    }

    final selectedContacts = contacts.where((c) => c.isSelected && c.exists).toList();
    return selectedContacts.isNotEmpty;
  }

  static Future<Map<String, dynamic>?> _getUserData(SharedPreferences prefs) async {
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Montant (FCFA)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: motifController,
          decoration: const InputDecoration(
            labelText: 'Motif du transfert',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Je paie les frais de transfert'),
          value: paysFees,
          onChanged: togglePaysFees,
        ),
      ],
    );
  }
}