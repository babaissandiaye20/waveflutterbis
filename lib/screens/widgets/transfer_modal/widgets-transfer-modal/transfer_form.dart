import 'package:flutter/material.dart';
import 'package:waveflutter/services/transfer_service.dart';
import 'package:waveflutter/models/contact.dart';

class TransferForm extends StatefulWidget {
  final TextEditingController amountController;
  final TextEditingController motifController;
  final bool paysFees;
  final ValueChanged<bool> togglePaysFees;
  final String token;
  final TransferService transferService;
  final List<Contact> contacts;  // Ajout de cette ligne

  const TransferForm({
    Key? key,
    required this.amountController,
    required this.motifController,
    required this.paysFees,
    required this.togglePaysFees,
    required this.token,
    required this.transferService,
    required this.contacts,  // Ajout de cette ligne
  }) : super(key: key);

  @override
  TransferFormState createState() => TransferFormState();
}

class TransferFormState extends State<TransferForm> {
  void initiateTransfer() {
    widget.transferService.performTransfer(
      isScheduled: false,
      contacts: widget.contacts,  // Utilisation des contacts passés
      amount: widget.amountController.text,
      motif: widget.motifController.text,
      selectedDate: null,
      selectedTime: null,
      selectedFrequency: '',
      paysFees: widget.paysFees,
      token: widget.token,
      onAuthError: () {
        // Gérer la déconnexion
      },
      updateBalance: () {
        // Gérer la mise à jour du solde
      },
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      },
      onSuccess: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Fermer le modal après succès
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Montant (FCFA)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.motifController,
          decoration: const InputDecoration(
            labelText: 'Motif du transfert',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Je paie les frais de transfert'),
          value: widget.paysFees,
          onChanged: widget.togglePaysFees,
        ),
        ElevatedButton(
          onPressed: initiateTransfer,
          child: const Text('Effectuer le transfert'),
        ),
      ],
    );
  }
}