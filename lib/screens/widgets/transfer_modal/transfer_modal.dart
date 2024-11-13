import 'package:flutter/material.dart';
import 'widgets-transfer-modal/date_time_pickers.dart';
import 'widgets-transfer-modal/frequency_dropdown.dart';
import 'widgets-transfer-modal/transfer_form.dart';
import 'widgets-transfer-modal/user_list.dart';
import 'package:waveflutter/models/contact.dart';
import 'package:waveflutter/services/transfer_service.dart';

// Définir le type pour le callback de sélection de contact
typedef ContactSelectionCallback = void Function(Contact);

class TransferModal extends StatefulWidget {
  final String token;
  final Function onAuthError;
  final Function updateBalance;
   final TransferService transferService;

  const TransferModal({
    Key? key,
    required this.token,
    required this.onAuthError,
    required this.updateBalance,
    required this.transferService,
  }) : super(key: key);

  @override
  State<TransferModal> createState() => _TransferModalState();
}

class _TransferModalState extends State<TransferModal> with SingleTickerProviderStateMixin {
  final GlobalKey<TransferFormState> _transferFormKey = GlobalKey<TransferFormState>();
   late TabController _tabController;
  late TextEditingController _amountController;
  late TextEditingController _motifController;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1)); // Initialisation directe
  TimeOfDay selectedTime = TimeOfDay.now(); // Initialisation directe
  String selectedFrequency = 'monthly';
  List<Contact> contacts = [];
  bool isLoading = false;
  bool paysFees = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _amountController = TextEditingController();
    _motifController = TextEditingController();
    _loadContacts();
  }

  // Le@override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose(); // Libérer la mémoire
    _motifController.dispose(); // Libérer la mémoire
    super.dispose();
  }

  Future<void> _loadContacts() async {
    await UserList.loadContacts(
        contacts, widget.token, (e) => _showError(e.toString()));
    setState(() => isLoading = false);
  }


  // ...

  void _performTransfer(bool isScheduled) {
    _transferFormKey.currentState?.initiateTransfer();
  }

   void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Transfert'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Transfert immédiat'),
              Tab(text: 'Transfert programmé'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTransferTab(false),
            _buildTransferTab(true),
          ],
        ),
      ),
    );
  } 

 Widget _buildTransferTab(bool isScheduled) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TransferForm(
          key: _transferFormKey,
          amountController: _amountController,
          motifController: _motifController,
          paysFees: paysFees,
          togglePaysFees: (value) => setState(() => paysFees = value),
          token: widget.token,
          transferService: widget.transferService,
          contacts: contacts,  // Ajout de cette ligne
        ),
          if (isScheduled) ...[
            DateTimePickers(
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              onDateChanged: (date) => setState(() => selectedDate = date),
              onTimeChanged: (time) => setState(() => selectedTime = time),
            ),
            FrequencyDropdown(
              selectedFrequency: selectedFrequency,
              onFrequencyChanged: (value) => setState(() => selectedFrequency = value ?? 'monthly'),
            ),
          ],
          UserList(
            contacts: contacts,
            isLoading: isLoading,
            onContactSelected: (Contact contact, bool? value) {
              setState(() {
                contact.isSelected = value ?? false;
              });
            },
          ),
          ElevatedButton(
            onPressed: isLoading ? null : () => _performTransfer(isScheduled),
            child: Text(isScheduled
                ? 'Programmer le transfert'
                : 'Effectuer le transfert'),
          ),
        ],
      ),
    );
  }
}
