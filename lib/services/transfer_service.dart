import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:waveflutter/models/contact.dart';

class TransferService {
  static const String baseUrl = 'http://192.168.6.144:8000/api';

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return null;
    return token.startsWith('Bearer ') ? token : 'Bearer $token';
  }

  Future<void> performTransfer({
    required bool isScheduled,
    required List<Contact> contacts,
    required String amount,
    required String motif,
    required bool paysFees,
    required String token,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? selectedFrequency,
    required Function onAuthError,
    required Function updateBalance,
    required Function(String) onError,
    required Function(String) onSuccess,
  }) async {
    try {
      // Validation des données
      if (!_validateTransfer(amount, contacts)) {
        onError('Veuillez vérifier les données du transfert');
        return;
      }

      // Récupération du token
      final authToken = await getAuthToken();
      if (authToken == null) {
        onError('Session expirée. Veuillez vous reconnecter.');
        onAuthError();
        return;
      }

      // Récupération des données utilisateur
      final userData = await _getUserData();
      if (userData == null) {
        onError('Impossible de récupérer les données utilisateur');
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
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: json.encode(transferData),
      );

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

  bool _validateTransfer(String amount, List<Contact> contacts) {
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

  Future<Map<String, dynamic>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  void _handleErrorResponse(http.Response response, Function(String) onError) {
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
}