import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/screens/history/history.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'package:leaf_problem_detection/main.dart';
import 'package:http/http.dart' as http;
import 'package:leaf_problem_detection/utils/files.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  Home();

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _currentTabIndex = 0;
  Color _pageColor = Color.fromRGBO(24, 165, 123, 1);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final Firestore _db = Firestore.instance;

  // setUpLang() async {
  //   String path = _url.toString() +
  //       "/diseases?loc=" +
  //       DemoLocalizations.of(context).locale.languageCode +
  //       "&uid=" +
  //       _username.toString();
  //   var request = await http.post(path);
  // }

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((event) {
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
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
              steps = getText(message['notification']['body'].toString());
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
                Text(DemoLocalizations.of(context).vals["History"]
                        ["highChance"] +
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
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height / 40),
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

  List<Widget> getText(String text) {
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

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    return Future<void>.value();
  }

  _saveDeviceToken() async {
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

  @override
  Widget build(BuildContext context) {
    // setUpLang();
    BottomNavigationBarItem _bottomIcons(IconData icon, double size) {
      return BottomNavigationBarItem(
        icon: Icon(icon, size: size),
        title: Text(""),
      );
    }

    return Scaffold(
      body: Navigator(key: _navigatorKey, onGenerateRoute: generateRoute),
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: Colors.white,
        backgroundColor: _pageColor,
        height: 55.0,
        items: [
          Icon(
            Icons.camera_alt,
            size: 30.0,
            color: _currentTabIndex == 0
                ? Color.fromRGBO(24, 165, 123, 1)
                : Colors.grey,
          ),
          Icon(
            Icons.local_florist,
            size: 30.0,
            color: _currentTabIndex == 1
                ? Color.fromRGBO(24, 165, 123, 1)
                : Colors.grey,
          ),
          Icon(
            Icons.nature,
            size: 30.0,
            color: _currentTabIndex == 2
                ? Color.fromRGBO(24, 165, 123, 1)
                : Colors.grey,
          ),
        ],
        onTap: (index) {
          if (index != _currentTabIndex) {
            switch (index) {
              case 0:
                _navigatorKey.currentState.pushReplacementNamed("0");
                _pageColor = Color.fromRGBO(24, 165, 123, 1);
                break;
              case 1:
                _navigatorKey.currentState.pushReplacementNamed("1");
                _pageColor = Color.fromRGBO(24, 165, 123, 1);
                break;
              case 2:
                _navigatorKey.currentState.pushReplacementNamed("2");
                //_pageColor = Color.fromRGBO(213, 223, 230, 1);
                _pageColor = Color.fromRGBO(24, 165, 123, 1);
                break;
              case 3:
                _navigatorKey.currentState.pushReplacementNamed("3");
                _pageColor = Colors.yellow;
                break;
              case 4:
                _navigatorKey.currentState.pushReplacementNamed("4");
                _pageColor = Colors.white;
                break;
              default:
                _navigatorKey.currentState.pushReplacementNamed("0");
                _pageColor = Color.fromRGBO(24, 165, 123, 1);
                break;
            }
            setState(() {
              _currentTabIndex = index;
            });
          }

          //_myIndex = index;
        },
      ),
    );
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "0":
        return MaterialPageRoute(builder: (context) => Upload(null, null));
      case "1":
        return MaterialPageRoute(builder: (context) => Upload(null, null));
      case "2":
        return MaterialPageRoute(builder: (context) => Upload(null, null));
      default:
        return MaterialPageRoute(builder: (context) => Upload(null, null));
    }
  }
}
