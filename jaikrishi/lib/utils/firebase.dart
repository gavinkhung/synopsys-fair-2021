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
import 'package:share/share.dart';

import 'imageProcessing.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
Firestore _firebaseStore = Firestore.instance;
bool justSignedUp = false;
int selectedIndex = 0;

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

Future pickLang(BuildContext context) {
  //create field variable: int selectedIndex = 0;
  String ans;
  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(100),
        topRight: Radius.circular(100),
      ),
    ),
    useRootNavigator: true,
    context: context,
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
                      "Select your preferred language",
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
                          onTap: () {
                            DemoLocalizations.of(context).locale =
                                new Locale("en");
                            DemoLocalizations.of(context).setVals();
                            ans = "en";
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                          leading: Icon(
                            Icons.favorite,
                            color:
                                selectedIndex == 0 ? Colors.red : Colors.grey,
                          ),
                          title: Text("English"),
                          trailing: Icon(
                            selectedIndex == 0 ? Icons.check : null,
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 30),
                          onTap: () {
                            DemoLocalizations.of(context).locale =
                                new Locale("hi");
                            DemoLocalizations.of(context).setVals();

                            ans = "hi";
                            setState(() {
                              selectedIndex = 2;
                            });
                          },
                          leading: Icon(
                            Icons.star,
                            color:
                                selectedIndex == 2 ? Colors.red : Colors.grey,
                          ),
                          title: Text("Hindi"),
                          trailing: Icon(
                            selectedIndex == 2 ? Icons.check : null,
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

StreamBuilder autoLogin(BuildContext cont) {
  sendAnalyticsEvent(cont);
  return StreamBuilder(
    stream: _auth.onAuthStateChanged,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        FirebaseUser user = snapshot.data;

        DemoLocalizations.of(cont).setVals();
        Future.delayed(Duration.zero, () {
          pickLang(cont);
        });
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

FutureBuilder showUsername(String uid, TextEditingController controller) {
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

Widget notifBody(DateTime dt, DocumentSnapshot notifs, BuildContext context) {
  if (notifs["type"] == "date_notif") {
    String step1 = "";
    String step2 = "";
    String step3 = "";
    String days = "";
    notifs["steps"][0]["Step 1"] != null && notifs["steps"][0]["Step 1"] != ""
        ? step1 = "1. " + notifs["steps"][0]["Step 1"]
        : "";
    notifs["steps"][0]["Step 2"] != null && notifs["steps"][0]["Step 2"] != ""
        ? step2 = "2. " + notifs["steps"][0]["Step 2"]
        : "";
    notifs["steps"][0]["Step 3"] != null && notifs["steps"][0]["Step 3"] != ""
        ? step3 = "3. " + notifs["steps"][0]["Step 3"]
        : "";
    notifs["steps"][0]["Days"] != null && notifs["steps"][0]["Days"] != ""
        ? days = notifs["steps"][0]["Days"]
        : "";

    return Column(children: [
      Text(DemoLocalizations.of(context).vals["History"]["based"].toString() +
          days.toString() +
          DemoLocalizations.of(context).vals["History"]["days"].toString() +
          DemoLocalizations.of(context).vals["History"]["recomend"].toString()),
      Text(step1),
      Text(step2),
      Text(step3),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FlatButton.icon(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.share),
                label: Text(DemoLocalizations.of(context)
                    .vals["DiseaseDetection"]["10"]),
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  Share.share(
                      "JaiKrishi" +
                          DemoLocalizations.of(context).vals["History"]
                              ["warningNotif"] +
                          step1 +
                          " " +
                          step2 +
                          " " +
                          step3,
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size);
                },
              ),
            );
          },
        ),
        Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              dt.day.toString() +
                  "/" +
                  dt.month.toString() +
                  "/" +
                  dt.year.toString() +
                  " ",
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.w300),
            ))
      ]),
    ]);
  }

  String tp = Provider.of<UserModel>(context, listen: false)
      .data[notifs["type"]]["Disease"];
  return Column(
    children: [
      Center(
        child: Text(
            DemoLocalizations.of(context).vals["History"]["highChance"] +
                tp +
                DemoLocalizations.of(context).vals["History"]["present"],
            style: TextStyle(fontSize: 20)),
      ),
      imageType(context, notifs['type']),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Builder(
          builder: (BuildContext context) {
            return Center(
              child: FlatButton.icon(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.share),
                label: Text(DemoLocalizations.of(context)
                    .vals["DiseaseDetection"]["10"]),
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  Share.share(
                      "JaiKrishi" +
                          DemoLocalizations.of(context).vals["History"]
                              ["warns"] +
                          tp +
                          DemoLocalizations.of(context).vals["History"]
                              ["warningDisease"],
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size);
                },
              ),
            );
          },
        ),
        Text(
          dt.day.toString() +
              "/" +
              dt.month.toString() +
              "/" +
              dt.year.toString() +
              " ",
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.w300),
        )
      ])
    ],
  );
}

updateNotify(String uid, String id) {
  return Firestore.instance
      .collection("users")
      .document(uid)
      .collection("image_diseases")
      .document(id)
      .updateData({"status": "checked", "works": "yes"});
}
