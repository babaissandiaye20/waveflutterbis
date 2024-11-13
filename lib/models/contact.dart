// models/contact.dart
class Contact {
  final String id;
  final String name;
  final String? phoneNumber;
  bool isSelected;
  bool exists;

  Contact({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.isSelected = false,
    this.exists = false,
  });
}
