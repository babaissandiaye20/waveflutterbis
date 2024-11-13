import 'package:flutter/material.dart';

class FrequencyDropdown extends StatelessWidget {
  final String selectedFrequency;
  final ValueChanged<String?> onFrequencyChanged;

  const FrequencyDropdown({
    Key? key,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final frequencies = [
      {'value': 'monthly', 'label': 'Mensuel'},
      {'value': 'weekly', 'label': 'Hebdomadaire'},
      {'value': 'everyday', 'label': 'Quotidien'},
      {'value': 'everyminute', 'label': 'Chaque minute'},
    ];

    return DropdownButtonFormField<String>(
      value: selectedFrequency,
      decoration: const InputDecoration(
        labelText: 'Fréquence',
        border: OutlineInputBorder(),
      ),
      items: frequencies
          .map((freq) => DropdownMenuItem(
                value: freq['value'],
                child: Text(freq['label']!),
              ))
          .toList(),
      onChanged: (String? value) {
        if (value != null) {
          onFrequencyChanged(value);
        }
      },
    );
  }
}
