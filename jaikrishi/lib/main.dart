import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:provider/provider.dart';
import 'models/image_model.dart';
import 'models/user_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ImageModel(),
        ),
        Provider<FirebaseAnalytics>.value(value: analytics),
        Provider<FirebaseAnalyticsObserver>.value(value: observer),
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
      supportedLocales: [
        const Locale('en', ''),
        const Locale('hi', ''),
      ],
      home: App(),
      navigatorObservers: [Provider.of<FirebaseAnalyticsObserver>(context)],
      debugShowCheckedModeBanner: false,
    );
  }
}

class App extends StatefulWidget {
  App();
  @override
  _App createState() => _App();
}

Future<void> _sendAnalyticsEvent(BuildContext context) async {
  FirebaseAnalytics analytics = Provider.of<FirebaseAnalytics>(context);
  await analytics.logEvent(name: 'started_app', parameters: <String, dynamic>{
    'string': 'string',
    'int': 42,
    'long': 12345678910,
    'double': 42.0,
    'bool': true,
  });
}

class _App extends State<App> {
  Widget build(BuildContext context) {
    print("hi");
    _sendAnalyticsEvent(context);
    return Scaffold(
      body: autoLogin(context, Text("poo"), Upload(null, "")),
    );
  }
}
