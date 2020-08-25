import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/weather_model.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'models/weather_model.dart';
import 'models/user_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:location/location.dart' as loc;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => WeatherModel(),
        ),
        getAnalytics(),
        getAnalyticsProvider(),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: Color.fromRGBO(24, 165, 123, 1),
        accentColor: Colors.redAccent,
      ),
      supportedLocales: [
        const Locale('en', ''),
        const Locale('hi', ''),
      ],
      home: App(),
      navigatorObservers: getanalyticsNav(context),
      debugShowCheckedModeBanner: false,
    );
  }
}

class App extends StatefulWidget {
  App();
  @override
  _App createState() => _App();
}

class _App extends State<App> {
  initState() {}

  Widget build(BuildContext context) {
    return Scaffold(
      body: autoLogin(context),
    );
  }
}
