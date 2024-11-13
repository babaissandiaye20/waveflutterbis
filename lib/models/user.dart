class User {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? photoUrl;
  final String pin;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.pin,
  });
}
