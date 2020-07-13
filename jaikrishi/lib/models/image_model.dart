import 'dart:io';

import 'package:flutter/material.dart';

class ImageModel extends ChangeNotifier {
  File _image;
  String _response;

  String get response => _response;
  File get image => _image;

  set response(String val) {
    _response = val;
    notifyListeners();
  }

  set image(File val) {
    _image = val;
    notifyListeners();
  }
}
