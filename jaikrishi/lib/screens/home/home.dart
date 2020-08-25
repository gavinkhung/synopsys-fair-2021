import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/screens/chat/chat.dart';
import 'package:leaf_problem_detection/screens/history/history.dart';
import 'package:leaf_problem_detection/screens/home/profile.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'package:leaf_problem_detection/main.dart';
import 'package:http/http.dart' as http;
import 'package:leaf_problem_detection/utils/files.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
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

    setUpNotifs(context);
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
          // Icon(
          //   Icons.local_florist,
          //   size: 30.0,
          //   color: _currentTabIndex == 1
          //       ? Color.fromRGBO(24, 165, 123, 1)
          //       : Colors.grey,
          // ),
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
        //return MaterialPageRoute(builder: (context) => Upload(null, null));
        return MaterialPageRoute(builder: (context) => Chat());
      // case "1":
      //   return MaterialPageRoute(builder: (context) => History());
      case "2":
        return MaterialPageRoute(builder: (context) => profile());
      default:
        return MaterialPageRoute(builder: (context) => Chat());
    }
  }
}
