import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/models/weather_model.dart';
import 'package:leaf_problem_detection/screens/authentication/auth.dart';
import 'package:leaf_problem_detection/screens/home/home.dart';
import 'package:leaf_problem_detection/utils/files.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/location.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'imageProcessing.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
Firestore _firebaseStore = Firestore.instance;
bool justSignedUp = false;
int selectedIndex = 2;

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

Future pickLang(BuildContext cont, String uid) {
  //create field variable: int selectedIndex = 0;
  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(100),
        topRight: Radius.circular(100),
      ),
    ),
    useRootNavigator: true,
    context: cont,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Material(
          shadowColor: Colors.transparent,
          type: MaterialType.card,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: IntrinsicHeight(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      "भाषा (Language)",
                      style: TextStyle(color: Colors.black),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    leading: GestureDetector(
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                          onTap: () async {
                            DemoLocalizations.of(context).locale =
                                new Locale("hi");
                            DemoLocalizations.of(context).setVals();
                            String url = await getUrl();
                            Provider.of<UserModel>(cont, listen: false).data =
                                await loadJson(url, cont, "hi");
                            if (uid != "") {
                              analytics.logEvent(
                                  name: "lang_switched",
                                  parameters: {"lang": "Hindi"});
                              Map<String, dynamic> temp = {"lang": "hi"};
                              updateUser(uid, temp);
                            }
                            Navigator.pop(context);
                            setState(() {
                              selectedIndex = 2;
                            });
                          },
                          title: Text("हिन्दी"),
                          trailing: Icon(
                            selectedIndex == 2 ? Icons.check : null,
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                          onTap: () async {
                            DemoLocalizations.of(context).locale =
                                new Locale("en");
                            DemoLocalizations.of(context).setVals();
                            String url = await getUrl();
                            Provider.of<UserModel>(cont, listen: false).data =
                                await loadJson(url, cont, "en");
                            if (uid != "") {
                              analytics.logEvent(
                                  name: "lang_switched",
                                  parameters: {"lang": "English"});
                              Map<String, dynamic> temp = {"lang": "en"};
                              updateUser(uid, temp);
                            }
                            Navigator.pop(context);
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                          title: Text("English"),
                          trailing: Icon(
                            selectedIndex == 0 ? Icons.check : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    },
  );
}

Future<bool> signOut() async {
  try {
    await _auth.signOut();
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

StreamBuilder autoLogin(BuildContext cont) {
  sendAnalyticsEvent(cont);
  return StreamBuilder(
    stream: _auth.onAuthStateChanged,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        FirebaseUser user = snapshot.data;

        if (user == null) {
          return FutureBuilder<List<String>>(
            future: getUrlAndLink(),
            builder: (context, data) {
              if (data.hasData) {
                Provider.of<UserModel>(context, listen: false).url =
                    data.data.first;
                DemoLocalizations.of(cont).firstSet(data.data.first);
                Provider.of<UserModel>(context, listen: false).tutLink =
                    data.data.last;
                justSignedUp = true;
                return FutureBuilder(
                    future: DemoLocalizations.of(cont).setVals(),
                    builder: (context, data) {
                      if (data.hasData) {
                        return Auth(false, false);
                      } else {
                        return CircularProgressIndicator();
                      }
                    });
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        } else {
          if (_auth.currentUser() != null && !justSignedUp) {
            analytics.logLogin();
            print(user.uid);
            return FutureBuilder(
              future: setVals(cont, user),
              builder: (context, data) {
                if (data.hasData) {
                  return FutureBuilder(
                      future: getData(user.uid),
                      builder: (context, data) {
                        if (data.hasData) {
                          DemoLocalizations.of(cont).locale = new Locale(
                              data.data["lang"] != null
                                  ? data.data["lang"]
                                  : "hi");
                          return Home();
                        } else {
                          return CircularProgressIndicator();
                        }
                      });
                } else {
                  analytics.logEvent(name: "set_vals_failed");
                  return CircularProgressIndicator();
                }
              },
            );
          }

          return Container();
        }
      } else {
        analytics.logEvent(name: "snapshot_data_null");
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
  return ref["newIP"];
}

Future<List<String>> getUrlAndLink() async {
  List<String> list = new List<String>();
  var url =
      await Firestore.instance.collection("data").document("backend").get();
  list.add(url["newIP"]);
  list.add(url["tutorialLink"]);
  return list;
}

Future<bool> setVals(BuildContext context, FirebaseUser user) async {
  UserModel userModel = Provider.of<UserModel>(context, listen: false);
  try {
    userModel.uid = user.uid;
  } catch (e) {
    print(e);
    userModel.uid = "";
  }

  DocumentSnapshot data = await getData(user.uid);
  try {
    userModel.seed = data.data["seed"].toDate();
  } catch (e) {
    print(e.toString());
    userModel.seed = null;
  }
  try {
    userModel.trans = data.data["trans"].toDate();
  } catch (e) {
    print(e.toString());
    userModel.trans = null;
  }
  try {
    userModel.type = data.data["type"];
  } catch (e) {
    print(e.toString());
    userModel.type = null;
  }
  try {
    userModel.crop = data.data["crop"];
  } catch (e) {
    userModel.crop = null;

    print(e.toString());
  }
  try {
    userModel.phoneNumber = data.data["phone"];
  } catch (e) {
    userModel.phoneNumber = null;
  }

  String locData = "20 79";
  try {
    locData = data.data["location"];
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
  } catch (e) {
    print(e.toString());
    userModel.loc = new LatLng(20, 79);
  }

  String url = await getUrl();
  userModel.url = url;
  if (locData.indexOf(" ") != -1) {
    try {
      Coordinates coords = new Coordinates(
          double.parse(locData.substring(0, locData.indexOf(" "))),
          double.parse(locData.substring(locData.indexOf(" ") + 1)));
      Geocoder.local
          .findAddressesFromCoordinates(coords)
          .then((value) => userModel.address = value.first.addressLine);
    } catch (e) {
      print(e.toString());
      analytics.logEvent(name: "geocoder_failed");
      userModel.address =
          DemoLocalizations.of(context).vals["error"]["Address"];
    }
    setWeatherData(
        user.uid,
        context,
        locData.substring(0, locData.indexOf(" ")),
        locData.substring(locData.indexOf(" ") + 1));
  }
  String lang = null;
  try {
    lang = data.data["lang"];
    DemoLocalizations.of(context).locale = new Locale(lang);
    DemoLocalizations.of(context).setVals();
  } catch (e) {
    print(e.toString());
  }

  userModel.data = await loadJson(url, context, lang != null ? lang : "hi");

  return true;
}

Future<bool> setWeatherData(
    String uid, BuildContext context, String lat, String long) {
  return getWeatherData(uid, lat, long).then((weather) {
    WeatherModel wData = Provider.of<WeatherModel>(context, listen: false);
    wData.loc = new LatLng(double.parse(lat), double.parse(long));
    wData.temp = weather['main']['temp'].round().toString();
    wData.minTemp = weather['main']['temp_min'].round().toString();
    wData.maxTemp = weather['main']['temp_max'].round().toString();
    wData.humidity = weather['main']['humidity'].toString();
    wData.typeWeather = weather['weather'][0]['main'].toString();
    wData.day = DateFormat.yMMMEd().format(DateTime.now());
    wData.id = weather['weather'][0]['icon'].toString();
    return true;
  });
}

Future<QuerySnapshot> getPrevNotifs(String _uid) {
  return _firebaseStore
      .collection("users")
      .document(_uid)
      .collection("daily_diseases")
      .getDocuments();
}

Future<QuerySnapshot> getPrevDisease(String _uid) {
  return _firebaseStore
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
      analytics.logEvent(name: "notification_received");
      // showDialog<void>(
      //   context: context, // user must tap button!
      //   builder: (BuildContext context) {
      //     return CupertinoAlertDialog(
      //       title: Column(
      //         children: [
      //           Text(message['notification']['title']),
      //           Divider(
      //             color: Color.fromRGBO(24, 165, 123, 1),
      //           )
      //         ],
      //       ),
      //       content: Container(
      //         padding: EdgeInsets.all(MediaQuery.of(context).size.height / 40),
      //         child: Column(children: [Text(message['notification']['body'])]),
      //       ),
      //       actions: <Widget>[
      //         CupertinoDialogAction(
      //           child: Icon(
      //             Icons.check,
      //             color: Color.fromRGBO(24, 165, 123, 1),
      //           ),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
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

FutureBuilder showUsername(String uid, TextEditingController controller) {
  return FutureBuilder<DocumentSnapshot>(
      future: getData(uid),
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

updateNotify(String uid, String id) {
  return _firebaseStore
      .collection("users")
      .document(uid)
      .collection("image_diseases")
      .document(id)
      .updateData({"status": "checked", "works": "yes"});
}

updateUser(String uid, Map<String, dynamic> data) {
  return _firebaseStore.collection("users").document(uid).updateData(data);
}

updateUserWeather(String uid, LocationData loc) {
  Map<String, dynamic> data = {
    "location": loc.latitude.toString() + " " + loc.longitude.toString()
  };
  updateUser(uid, data);
}
