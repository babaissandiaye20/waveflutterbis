// services/contact_service.dart
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'interfaces/IContactService.dart';
import 'interfaces/IApiService.dart';
import 'package:waveflutter/models/contact.dart';


class ContactService implements IContactService {
  final IApiService _apiService;

  ContactService(this._apiService);

  @override

  Future<List<Contact>> loadContacts() async {
    if (!await flutter_contacts.FlutterContacts.requestPermission()) {
      throw Exception('Permission de contacts refusée');
    }

    final phoneContacts = await flutter_contacts.FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    return phoneContacts
        .where((contact) => contact.phones.isNotEmpty)
        .map((contact) => Contact(
              id: contact.id,
              name: contact.displayName,
              phoneNumber:
                  contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), ''),
            ))
        .toList();
  }

  @override
  Future<List<String>> verifyPhoneNumbers(List<String> phoneNumbers) async {
    try {
      final response = await _apiService.post(
        'verify-accounts',
        data: {'telephone': phoneNumbers},
      );

      if (response['success']) {
        return List<String>.from(response['existingPhones']);
      }
      return [];
    } catch (e) {
      throw Exception(
          'Erreur lors de la vérification des numéros: ${e.toString()}');
    }
  }
}
