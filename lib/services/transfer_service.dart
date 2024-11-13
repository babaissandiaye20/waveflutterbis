import 'package:waveflutter/models/contact.dart';
import 'package:waveflutter/services/interfaces/IApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waveflutter/services/ApiService.dart';
import 'dart:convert';

class TransferService {
  final ApiService _apiService;
  static const String baseUrl = 'http://192.168.6.144:8000/api';

  TransferService(this._apiService);

  Future<List<Contact>> getContacts() async {
    // Implement the logic to fetch and return the contacts
    // You can use the flutter_contacts package or any other means to fetch the contacts
    final List<Contact> contacts = [];
    // Add your contact fetching logic here
    return contacts;
  }

  Future<Map<String, dynamic>> verifyPhoneNumbers(
      List<String> phoneNumbers) async {
    return await _apiService
        .post('$baseUrl/verify-accounts', data: {'telephone': phoneNumbers});
  }

  Future<Map<String, dynamic>> performTransfer(
      Map<String, dynamic> transferData) async {
    return await _apiService.post('$baseUrl/transactions', data: transferData);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
}