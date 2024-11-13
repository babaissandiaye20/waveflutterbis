import 'package:flutter/material.dart';
import 'package:waveflutter/models/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:http/http.dart' as http;
import 'dart:convert';

// Définir un type pour la fonction callback
typedef ContactSelectionCallback = void Function(Contact contact, bool? value);

class UserList extends StatelessWidget {
  final List<Contact> contacts;
  final bool isLoading;
  final ContactSelectionCallback onContactSelected;

  const UserList({
    Key? key,
    required this.contacts,
    required this.isLoading,
    required this.onContactSelected,
  }) : super(key: key);

  static Future<void> loadContacts(
    List<Contact> contacts,
    String token,
    Function(Object) onError,
  ) async {
    try {
      if (await flutter_contacts.FlutterContacts.requestPermission()) {
        final phoneContacts = await flutter_contacts.FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );

        final contactsList = phoneContacts
            .where((contact) => contact.phones.isNotEmpty)
            .map((contact) => Contact(
                  id: contact.id,
                  name: contact.displayName,
                  phoneNumber: contact.phones.first.number.replaceAll(RegExp(r'[^\d+]'), ''),
                ))
            .toList();

        contacts.clear();
        contacts.addAll(contactsList);

        await _verifyPhoneNumbers(contacts, token, onError);
      }
    } catch (e) {
      onError('Erreur lors du chargement des contacts: $e');
    }
  }

  static Future<void> _verifyPhoneNumbers(
    List<Contact> contacts,
    String token,
    Function(String) onError,
  ) async {
    try {
      final phoneNumbers = contacts
          .where((contact) => contact.phoneNumber != null)
          .map((contact) => contact.phoneNumber!)
          .toList();

      final response = await http.post(
        Uri.parse('http://192.168.6.144:8000/api/verify-accounts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'telephone': phoneNumbers}),
      );

      if (response.statusCode == 401) {
        onError('Session expirée. Veuillez vous reconnecter.');
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final existingPhones = List<String>.from(data['existingPhones']);
          for (var contact in contacts) {
            if (contact.phoneNumber != null) {
              contact.exists = existingPhones.contains(contact.phoneNumber);
            }
          }
        }
      }
    } catch (e) {
      onError('Erreur lors de la vérification des numéros: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return CheckboxListTile(
          title: Text(
            contact.name,
            style: TextStyle(
              color: contact.exists ? Colors.black : Colors.grey,
            ),
          ),
          subtitle: Row(
            children: [
              Text(contact.phoneNumber ?? 'Pas de numéro'),
              if (!contact.exists)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    '(Non enregistré)',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          value: contact.isSelected,
          onChanged: contact.exists 
              ? (bool? value) => onContactSelected(contact, value)
              : null,
        );
      },
    );
  }
}