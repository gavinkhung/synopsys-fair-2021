import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/screens/home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaf_problem_detection/screens/login/anon_login.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class DemoLocalizations {
  DemoLocalizations(this.locale);

  final Locale locale;

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  Map<dynamic, dynamic> vals;

  setVals() async {
    vals = await rootBundle
        .loadString("data/" + locale.languageCode + ".json")
        .then((value) {
      return jsonDecode(value);
    }).catchError((e) {
      print(e);
    });
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

class MyApp extends StatelessWidget {
  const MyApp() : super();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('hi', ''),
      ],
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: App(),
      ),
    );
  }
}

class App extends StatefulWidget {
  App();
  @override
  _App createState() => _App();
}

class _App extends State<App> {
  // This widget is the root of your application.

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Widget currentScreen;
  String url;

  Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> hello(String local, String uid) async {
    var temp1 = setUpUrl();
    var temp2 = _localPath();
    String k = await temp1;
    String temp = await temp2;
    File data = File('$temp/data.json');
    String json = await getData(k, local, uid);
    data.writeAsString(json);
    return "hello:";
  }

  Future<String> setUpUrl() async {
    var ref =
        await Firestore.instance.collection("data").document("backend").get();
    url = ref["ip"];
    return url;
  }

  Future<String> getData(String u, String local, String uid) async {
    String path = u.toString() +
        "/diseases?loc=" +
        local.toString() +
        "&uid=" +
        uid.toString();
    var request = await http.post(path);
    return request.body;
  }

  @override
  void initState() {
    // setUpUrl();
    super.initState();

    // email and password
  }

  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<loc.LocationData> getLocation() async {
    this.requestLocationPermission();
    loc.Location location = new loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {}
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {}
    }

    return _locationData = await location.getLocation();
  }

  Future<bool> requestLocationPermission() async {
    return requestPermission(PermissionGroup.locationWhenInUse);
  }

  Future<bool> requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            // return
            return FutureBuilder(
                future: hello(
                    DemoLocalizations.of(context).locale.languageCode, ""),
                builder: (context, data) {
                  DemoLocalizations.of(context).setVals();
                  if (data.hasData) {
                    return FutureBuilder<loc.LocationData>(
                        future: getLocation(),
                        builder: (context, data) {
                          if (data.hasData) {
                            var userLoc = new LatLng(
                                data.data.latitude, data.data.longitude);
                            return Anonymous_Signin(false, url, userLoc);
                          } else {
                            return Container();
                          }
                        });
                  } else {
                    return Container();
                  }
                });
          }
          // return ;
          return FutureBuilder(
              future: hello(
                  DemoLocalizations.of(context).locale.languageCode, user.uid),
              builder: (context, data) {
                DemoLocalizations.of(context).setVals();
                if (data.hasData) {
                  return Home(user.uid, url);
                } else {
                  return Container();
                }
              });
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }
}
