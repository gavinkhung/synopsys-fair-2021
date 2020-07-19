import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'firebase.dart';

import 'files.dart';

class DemoLocalizations {
  DemoLocalizations(this.locale);

  Locale locale;

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  Map<dynamic, dynamic> vals;
  Map<dynamic, dynamic> total;
  String _url;

  firstSet(String url) {
    _url = url;
  }

  Future<bool> setVals() async {
    try {
      if (vals == null) {
        if (_url == null) {
          _url = await getUrl();
        }
        String temp = await getTextData(_url);
        total = jsonDecode(temp);
      }
      vals = total[locale.languageCode];
    } catch (e) {
      print(e);
    }
    return true;
  }

  Map<String, dynamic> get valuess {
    return vals;
  }
}

class DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<DemoLocalizations>(DemoLocalizations(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
