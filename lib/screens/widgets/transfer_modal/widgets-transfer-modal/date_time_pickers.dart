import 'package:flutter/material.dart';

class DateTimePickers extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const DateTimePickers({
    Key? key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Date'),
          subtitle: Text(
            selectedDate == null 
              ? 'Sélectionner une date'
              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onDateChanged(date);
            }
          },
        ),
        ListTile(
          title: const Text('Heure'),
          subtitle: Text(
            selectedTime == null 
              ? 'Sélectionner une heure'
              : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
          ),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              onTimeChanged(time);
            }
          },
        ),
      ],
    );
  }
}