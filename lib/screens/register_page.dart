import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _selectedRole;
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _codeSecretController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  void _clearFields() {
    _prenomController.clear();
    _nomController.clear();
    _loginController.clear();
    _codeSecretController.clear();
    _telephoneController.clear();
    setState(() {
      _selectedRole = null;
      _selectedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Formatage des données avec le suffixe underscore pour le téléphone
        final data = {
          'prenom': _prenomController.text,
          'nom': _nomController.text,
          'login': _loginController.text,
          'codesecret': _codeSecretController.text,
          'role': _selectedRole,
          'telephone_': _telephoneController.text, // Ajout du underscore ici
        };

        final nonNullData = Map<String, String>.fromEntries(
          data.entries.where((entry) => entry.value != null).map(
            (entry) => MapEntry(entry.key, entry.value!),
          ),
        );

        // Déboggage - afficher les données envoyées
        print('Données à envoyer: $nonNullData');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.1.25:8000/api/utilisateurs')
        );
        
        request.fields.addAll(nonNullData);

        if (_selectedImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'photo', 
            _selectedImage!.path
          ));
        }

        request.headers.addAll({
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        });

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        // Déboggage - afficher la réponse du serveur
        print('Status code: ${response.statusCode}');
        print('Réponse du serveur: ${response.body}');

        if (response.statusCode == 201) {
          _clearFields();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inscription réussie! Redirection vers la page de connexion...'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              )
            );

            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            });
          }
        } else {
          var responseData = json.decode(response.body);
          String errorMessage;
          
          if (response.statusCode == 422) {
            if (responseData['errors']?['login'] != null) {
              errorMessage = 'Cet email existe déjà';
            } else if (responseData['errors']?['telephone_'] != null || 
                      responseData['message'].toString().toLowerCase().contains('telephone')) {
              errorMessage = 'Ce numéro de téléphone existe déjà';
            } else {
              errorMessage = responseData['message'] ?? 'Erreur de validation';
            }
          } else {
            errorMessage = responseData['message'] ?? 'Erreur lors de l\'inscription';
          }
          
          print('Erreur: ${response.statusCode}');
          print('Message d\'erreur: $errorMessage');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              )
            );
          }
        }
      } catch (e) {
        print('Exception: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur de connexion au serveur'),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    }
  }

  // Mise à jour de la validation du téléphone
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    // Supprime tous les espaces et caractères non numériques
    String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length != 9) {
      return 'Le numéro doit contenir exactement 9 chiffres';
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final double formWidth = isSmallScreen 
        ? screenSize.width 
        : screenSize.width < 1200 
            ? screenSize.width * 0.7 
            : screenSize.width * 0.4;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD700),
              Color(0xFFDAA520),
              Color(0xFF4A4A4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 20,
                ),
                child: Center(
                  child: SizedBox(
                    width: formWidth,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            width: isSmallScreen ? 100 : 120,
                            height: isSmallScreen ? 100 : 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.pets,
                                size: isSmallScreen ? 60 : 80,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Zigfreak Money',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 28 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Qualité & Excellence',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 40),

                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (!isSmallScreen)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _prenomController,
                                          label: 'Prénom',
                                          icon: Icons.person,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _nomController,
                                          label: 'Nom',
                                          icon: Icons.person_outline,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _buildTextField(
                                    controller: _prenomController,
                                    label: 'Prénom',
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    controller: _nomController,
                                    label: 'Nom',
                                    icon: Icons.person_outline,
                                  ),
                                ],
                                const SizedBox(height: 15),
                                _buildTextField(
                                  controller: _loginController,
                                  label: 'Email',
                                  icon: Icons.email,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 15),
                                _buildTextField(
                                  controller: _telephoneController,
                                  label: 'Téléphone',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhoneNumber,
                                ),
                                const SizedBox(height: 15),
                                _buildDropdownField(),
                                const SizedBox(height: 20),
                                _buildPhotoSection(isSmallScreen),
                                const SizedBox(height: 15),
                                _buildTextField(
                                  controller: _codeSecretController,
                                  label: 'Code PIN (6 chiffres)',
                                  icon: Icons.lock,
                                  isPassword: true,
                                  maxLength: 6,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                           const SizedBox(height: 30),
                          SizedBox(
                            width: isSmallScreen ? double.infinity : formWidth * 0.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 30 : 50,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              onPressed: _register,
                              child: Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    int? maxLength,
    TextInputType? keyboardType,
      String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        counterText: '',
      ),
      obscureText: isPassword,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: (value) => value?.isEmpty ?? true ? '$label est requis' : null,
      
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Rôle',
        prefixIcon: const Icon(Icons.work, color: Color(0xFFFFD700)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'client', child: Text('Client')),
        DropdownMenuItem(value: 'agent', child: Text('Agent')),
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRole = value;
        });
      },
      validator: (value) => value == null ? 'Le rôle est requis' : null,
    );
  }

  Widget _buildPhotoSection(bool isSmallScreen) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Ajouter une photo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 15 : 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _pickImage,
        ),
        if (_selectedImage != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              height: isSmallScreen ? 80 : 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}