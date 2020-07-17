import 'dart:io';

import 'package:flutter/material.dart';

class WeatherModel extends ChangeNotifier {
  String _humidity, _typeWeather, _temp, _minTemp, _maxTemp, _day, _id;

  String get humidity => _humidity;
  String get typeWeather => _typeWeather;
  String get temp => _temp;
  String get minTemp => _minTemp;
  String get maxTemp => _maxTemp;
  String get day => _day;
  String get id => _id;

  set humidity(String val) {
    _humidity = val;
    notifyListeners();
  }

  set typeWeather(String val) {
    _typeWeather = val;
    notifyListeners();
  }

  set temp(String val) {
    _temp = val;
    notifyListeners();
  }

  set minTemp(String val) {
    _minTemp = val;
    notifyListeners();
  }

  set maxTemp(String val) {
    _maxTemp = val;
    notifyListeners();
  }

  set day(String val) {
    _day = val;
    notifyListeners();
  }

  set id(String val) {
    _id = val;
    notifyListeners();
  }

  toString() {
    return _humidity + " " + _typeWeather;
  }
}
