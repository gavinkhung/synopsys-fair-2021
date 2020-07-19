import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'files.dart';

class DemoLocalizations {
  DemoLocalizations(this.locale);

  Locale locale;

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  Map<dynamic, dynamic> vals;
  Map<dynamic, dynamic> total;

  setVals() async {
    if (vals == null) {
      String temp = await getText();
      total = jsonDecode(temp);
    }
    vals = total[locale.languageCode];
    // vals = await rootBundle
    //     .loadString("data/" + locale.languageCode + ".json")
    //     .then((value) {
    //   return jsonDecode(value);
    // }).catchError((e) {
    //   print(e);
    // });
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
