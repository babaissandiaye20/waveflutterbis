import 'package:flutter/material.dart';

class BalanceProvider extends ChangeNotifier {
  double _balance = 0;

  double get balance => _balance;

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }
}
