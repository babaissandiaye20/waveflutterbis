
// widgets/action_buttons.dart
import 'package:flutter/material.dart';
import 'transfer_modal/transfer_modal.dart';
import 'package:waveflutter/services/transfer_service.dart';
import 'package:waveflutter/services/interfaces/IHttpClient.dart';
import 'package:waveflutter/services/ApiService.dart';

class ActionButtons extends StatelessWidget {
  final TransferService transferService;

  ActionButtons({Key? key, required IHttpClient httpClient})
      : transferService = TransferService(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.send,
            label: 'Transfert',
            color: const Color(0xFF6750A4),
            onTap: () => _showTransferModal(context),
          ),
          _buildActionButton(
            icon: Icons.account_balance_wallet,
            label: 'Dépôt',
            color: Colors.green,
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.receipt,
            label: 'Paiement',
            color: Colors.orange,
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.more_horiz,
            label: 'Retrait',
            color: Colors.purple,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  void _showTransferModal(BuildContext context) {
    const token = 'yourToken'; // ou récupérez le token de la manière appropriée

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransferModal(
        token: token,
        onAuthError: () {
          Navigator.pop(context);
        },
        updateBalance: () {
          print('Solde mis à jour');
        },
        transferService: transferService,
      ),
    );
  }
}