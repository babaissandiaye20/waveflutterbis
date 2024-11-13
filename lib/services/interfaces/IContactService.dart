// interfaces/IContactService.dart
import 'package:waveflutter/models/contact.dart';

abstract class IContactService {
  Future<List<Contact>> loadContacts();
  Future<List<String>> verifyPhoneNumbers(List<String> phoneNumbers);
}
