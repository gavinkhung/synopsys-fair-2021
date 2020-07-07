import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String _phoneNumber;
  String get phonNumber => _phoneNumber;
  set phoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }
}
