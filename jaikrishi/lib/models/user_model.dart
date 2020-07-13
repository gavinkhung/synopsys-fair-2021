import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String _phoneNumber;
  String _url;
  String _uid;
  DateTime _seed;
  DateTime _trans;
  String _crop;
  int _type;

  String get phoneNumber => _phoneNumber;
  String get url => _url;
  String get uid => _uid;
  DateTime get seed => _seed;
  DateTime get trans => _trans;
  String get crop => _crop;
  int get type => _type;

  set seed(DateTime val) {
    _seed = val;
    notifyListeners();
  }

  set trans(DateTime val) {
    _trans = val;
    notifyListeners();
  }

  set crop(String val) {
    _crop = val;
    notifyListeners();
  }

  set type(int val) {
    _type = val;
    notifyListeners();
  }

  set phoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  set uid(String val) {
    _uid = val;
    notifyListeners();
  }

  set url(String val) {
    _url = val;
    notifyListeners();
  }
}
