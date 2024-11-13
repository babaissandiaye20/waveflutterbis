import 'interfaces/IApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/contact.dart';
import 'package:flutter/material.dart';


class TransferService {
  final IApiService _apiService;

  TransferService(this._apiService);

  Future<void> performTransfer({
    required bool isScheduled,
    required List<Contact> contacts,
    required String amount,
    required String motif,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    required String selectedFrequency,
    required bool paysFees,
    required Function onAuthError,
    required Function updateBalance,
    required Function(String) onError,
    required Function(String) onSuccess,
  }) async {
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

      final storedToken = await _getStoredToken();
      if (storedToken == null || storedToken.isEmpty) {
        onError('Session expirée. Veuillez vous reconnecter.');
        onAuthError();
        return;
      }

      final selectedContacts =
          contacts.where((c) => c.isSelected && c.exists).toList();

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

      final response = await _apiService.post(
        'http://192.168.1.25:8000/api/transactions',
        data: json.encode(transferData),
      );

      if (response['statusCode'] == 401) {
        onError('Session expirée. Veuillez vous reconnecter.');
        onAuthError();
        return;
      }

      if (response['statusCode'] == 201 || response['statusCode'] == 200) {
        if (response['data']['success'] == true) {
          onSuccess(response['data']['message'] ?? 'Transfert effectué avec succès');
          updateBalance();
        } else {
          onError(response['data']['message'] ?? 'Une erreur est survenue');
        }
      } else {
        final errorMessage = response['data']['message'] ??
            response['data']['error'] ??
            'Erreur ${response['statusCode']}';
        onError(errorMessage);
      }
    } catch (e) {
      onError('Erreur lors du transfert: ${e.toString()}');
    }
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  bool _validateTransfer(String amount, List<Contact> contacts) {
    if (amount.isEmpty) return false;
    try {
      final double parsedAmount = double.parse(amount);
      if (parsedAmount <= 0) return false;
    } catch (e) {
      return false;
    }
    return contacts.any((c) => c.isSelected && c.exists);
  }

  Future<Map<String, dynamic>?> _getUserData(SharedPreferences prefs) async {
    final userDataString = prefs.getString('user_data');
    return userDataString != null ? json.decode(userDataString) : null;
  }
}
