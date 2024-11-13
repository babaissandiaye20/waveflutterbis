// interfaces/ITransactionService.dart
abstract class ITransactionService {
  Future<Map<String, dynamic>> performTransfer({
    required bool isScheduled,
    required List<String> receiverPhones,
    required double amount,
    required String motif,
    required bool paysFees,
    DateTime? scheduledDate,
    String? frequency,
  });
}
