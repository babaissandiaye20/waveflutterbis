// widgets/qr_buttons.dart
import 'package:flutter/material.dart';

class QRButtons extends StatelessWidget {
  const QRButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQRButton(
            icon: Icons.qr_code,
            label: 'Mon QR Code',
            onTap: () {},
          ),
          _buildQRButton(
            icon: Icons.qr_code_scanner,
            label: 'Scanner',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQRButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
