import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:provider/provider.dart';
import 'models/image_model.dart';
import 'models/user_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ImageModel(),
        ),
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
  Widget build(BuildContext context) {
    print("hi");
    return Scaffold(
      body: autoLogin(context, Text("poo"), Upload(null, "")),
    );
  }
}
