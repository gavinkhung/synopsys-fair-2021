import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf_problem_detection/screens/authentication/auth.dart';
import 'package:leaf_problem_detection/screens/home/home.dart';
import 'package:leaf_problem_detection/utils/files.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/location.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

FirebaseAuth _auth = FirebaseAuth.instance;
Firestore _firebaseStore = Firestore.instance;
bool justSignedUp = false;

final FirebaseAnalytics analytics = FirebaseAnalytics();
final FirebaseMessaging _fcm = FirebaseMessaging();
final Firestore _db = Firestore.instance;

FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

Future<void> sendAnalyticsEvent(BuildContext context) async {
  FirebaseAnalytics analytics = Provider.of<FirebaseAnalytics>(context);
  await analytics.logEvent(name: 'started_app', parameters: <String, dynamic>{
    'string': 'string',
    'int': 42,
    'long': 12345678910,
    'double': 42.0,
    'bool': true,
  });
}

List<NavigatorObserver> getanalyticsNav(BuildContext context) {
  return [Provider.of<FirebaseAnalyticsObserver>(context)];
}

dynamic getAnalytics() {
  return Provider<FirebaseAnalytics>.value(value: analytics);
}

dynamic getAnalyticsProvider() {
  return Provider<FirebaseAnalyticsObserver>.value(value: observer);
}

Future<FirebaseUser> getCurrUser() async {
  return await _auth.currentUser();
}

StreamBuilder autoLogin(BuildContext cont) {
  sendAnalyticsEvent(cont);
  return StreamBuilder(
    stream: _auth.onAuthStateChanged,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        FirebaseUser user = snapshot.data;
        DemoLocalizations.of(cont).setVals();
        if (user == null) {
          return FutureBuilder<String>(
            future: getUrl(),
            builder: (context, data) {
              if (data.hasData) {
                return FutureBuilder<LocationData>(
                  future: getLocation(),
                  builder: (context, loc) {
                    if (loc.hasData) {
                      Provider.of<UserModel>(context, listen: false).url =
                          data.data;
                      Provider.of<UserModel>(context, listen: false).loc =
                          LatLng(loc.data.latitude, loc.data.longitude);
                      justSignedUp = true;
                      return Auth(false);
                    } else {
                      print("loc");
                      return CircularProgressIndicator();
                    }
                  },
                );
              } else {
                print("url");
                return CircularProgressIndicator();
              }
            },
          );
        } else {
          if (_auth.currentUser() != null && !justSignedUp) {
            setVals(cont, user);
          }
          return FutureBuilder(
            future: setVals(cont, user),
            builder: (context, data) {
              if (data.hasData) {
                return Home();
              } else {
                return CircularProgressIndicator();
              }
            },
          );
          //return Home();
        }
      } else {
        return Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    },
  );
}

Future<DocumentSnapshot> getData(String uid) {
  return Firestore.instance.collection("users").document(uid).get();
}

Future<String> getUrl() async {
  var ref =
      await Firestore.instance.collection("data").document("backend").get();
  return ref["ip"];
}

Future<bool> setVals(BuildContext context, FirebaseUser user) async {
  print("UID" + user.uid);
  UserModel userModel = Provider.of<UserModel>(context, listen: false);
  userModel.uid = user.uid;
  DocumentSnapshot data = await getData(user.uid);
  userModel.seed = data.data["seed"].toDate();
  userModel.trans = data.data["trans"].toDate();
  userModel.type = data.data["type"];
  userModel.crop = data.data["crop"];
  userModel.phoneNumber = data.data["phone"];
  String locData = data.data["location"];

  LatLng loc = new LatLng(
    double.parse(
      locData.substring(
        0,
        locData.indexOf(" "),
      ),
    ),
    double.parse(
      locData.substring(
        locData.indexOf(" "),
      ),
    ),
  );
  userModel.loc = loc;
  String url = await getUrl();
  userModel.url = url;

  userModel.data = await loadJson(url, context, user.uid);
  return true;
}

Future<QuerySnapshot> getPrevNotifs(String _uid) {
  return Firestore.instance
      .collection("users")
      .document(_uid)
      .collection("daily_diseases")
      .getDocuments();
}

Future<QuerySnapshot> getPrevDisease(String _uid) {
  return Firestore.instance
      .collection("users")
      .document(_uid)
      .collection("image_diseases")
      .getDocuments();
}

Future signInAnonymous() async {
  try {
    AuthResult result = await _auth.signInAnonymously();
    FirebaseUser user = result.user;

    return user.uid;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

void setData(Map<String, dynamic> map, int version, BuildContext context) {
  if (version == 0) {
    _firebaseStore
        .collection("users")
        .document(Provider.of<UserModel>(context, listen: false).uid)
        .setData(
          map,
          merge: true,
        );
  }
}

void setUpNotifs(BuildContext context) {
  if (Platform.isIOS) {
    _fcm.onIosSettingsRegistered.listen((event) {
      _saveDeviceToken(context);
    });
    _fcm.requestNotificationPermissions(IosNotificationSettings());
  } else {
    _saveDeviceToken(context);
  }

  _fcm.configure(
    onMessage: (Map<String, dynamic> message) async {
      showDialog<void>(
        context: context, // user must tap button!
        builder: (BuildContext context) {
          List<Widget> steps = [
            Text(message['notification']['body'].toString()),
          ];
          if (message['notification']['body'].toString().startsWith("[")) {
            steps =
                getText(context, message['notification']['body'].toString());
          } else if (message['notification']['body']
              .toString()
              .startsWith("*")) {
            steps = [
              Text(message['notification']['body'].toString().substring(1))
            ];
          } else {
            String data = Provider.of<UserModel>(context, listen: false)
                .data[message['notification']['body'].toString()]["Disease"];
            steps = [
              Text(DemoLocalizations.of(context).vals["History"]["highChance"] +
                  data +
                  DemoLocalizations.of(context).vals["History"]["present"])
            ];
          }

          return CupertinoAlertDialog(
            title: Column(
              children: [
                Text(message['notification']['title']),
                Divider(
                  color: Color.fromRGBO(24, 165, 123, 1),
                )
              ],
            ),
            content: Container(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height / 40),
              child: Column(children: steps),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Icon(
                  Icons.check,
                  color: Color.fromRGBO(24, 165, 123, 1),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
    onLaunch: (Map<String, dynamic> message) async {},
    onResume: (Map<String, dynamic> message) async {},
  );
}

_saveDeviceToken(BuildContext context) async {
  String token = await _fcm.getToken();
  if (token != null) {
    FirebaseUser user = await _auth.currentUser();
    _db
        .collection('users')
        .document(Provider.of<UserModel>(context, listen: false).uid)
        .updateData({
      'token': token,
    });
  }
}

List<Widget> getText(BuildContext context, String text) {
  text = text.substring(2, text.length - 2);

  List<String> steps = text.split("',");
  List<Widget> stepWidgets = [];
  for (int i = 0; i < steps.length; i++) {
    if (steps[i].substring(0, steps[i].indexOf(":")).trim() == "\'Days\'") {
      String days = steps[i].substring(steps[i].indexOf(":") + 1);
      stepWidgets.add(new Text(DemoLocalizations.of(context).vals["History"]
              ["based"] +
          days.toString() +
          DemoLocalizations.of(context).vals["History"]["days"] +
          DemoLocalizations.of(context).vals["History"]["recomend"]));
      continue;
    }
  }
  for (int i = 0; i < steps.length; i++) {
    steps[i].replaceAll("'", "");
    if (steps[i].substring(0, steps[i].indexOf(":")).trim() == "\'Days\'")
      continue;
    stepWidgets.add(new Text(
      steps[i],
      textAlign: TextAlign.center,
    ));
    stepWidgets.add(
      new SizedBox(
        height: 10,
      ),
    );
  }
  return stepWidgets;
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  return Future<void>.value();
}

Future<Map> getWeatherData(String uid) async {
  DocumentSnapshot fb =
      await Firestore.instance.collection("users").document(uid).get();
  String lat = "20", long = "79";
  List<String> location = fb.data['location'].toString().split(" ");
  lat = location[0];
  long = location[1];
  String apiKey = await rootBundle.loadString("data/keys.json");
  String weatherKey = jsonDecode(apiKey)["weather"];
  String path = 'http://api.openweathermap.org/data/2.5/weather?lat=' +
      lat.toString() +
      '&lon=' +
      long.toString() +
      '&appid=' +
      weatherKey +
      '&units=metric';

  var request = await http.get(path);
  return json.decode(request.body);
}

FutureBuilder showUsername(String uid, TextEditingController controller{
  return FutureBuilder<DocumentSnapshot>(
      future: Firestore.instance.collection("users").document(uid).get(),
      builder: (context, data) {
        if (data.hasData) {
          if (data.data["name"] != null) controller.text = data.data["name"];
          return Container(
            width: MediaQuery.of(context).size.width / 8 * 7,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintMaxLines: 1,
                hintText: controller.text == ""
                    ? DemoLocalizations.of(context).vals["FirstPage"]["14"]
                    : "",
              ),
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height < 600 ? 20 : 30,
                  color: Colors.white),
              onSubmitted: (String s) {
                addUsername(uid, controller.text);
              },
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      });
}



  addUsername(String uid, String name) async {
    await Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({"name": name});
  }

