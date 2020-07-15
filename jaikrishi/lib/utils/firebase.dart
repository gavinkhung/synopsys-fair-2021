import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf_problem_detection/utils/files.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:provider/provider.dart';
import 'package:leaf_problem_detection/models/user_model.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics();
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

List<FirebaseAnalyticsObserver> getanalyticsNav(BuildContext context) {
  return [Provider.of<FirebaseAnalyticsObserver>(context)];
}

dynamic getAnalytics() {
  return Provider<FirebaseAnalytics>.value(value: analytics);
}

dynamic getAnalyticsProvider() {
  return Provider<FirebaseAnalyticsObserver>.value(value: observer);
}

StreamBuilder autoLogin(BuildContext cont, Widget success, Widget failed) {
  sendAnalyticsEvent(cont);
  return StreamBuilder(
    stream: FirebaseAuth.instance.onAuthStateChanged,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        FirebaseUser user = snapshot.data;
        if (user == null) {
          return Container(child: failed);
        } else {
          setVals(cont, user);
          DemoLocalizations.of(cont).setVals();
          return Container(child: success);
        }
      } else {
        return Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    },
  );
}

setVals(BuildContext context, FirebaseUser user) async {
  Provider.of<UserModel>(context, listen: false).uid = user.uid;
  DocumentSnapshot data = await getData(user.uid);
  Provider.of<UserModel>(context, listen: false).seed = data.data["seed"];
  Provider.of<UserModel>(context, listen: false).trans = data.data["trans"];
  Provider.of<UserModel>(context, listen: false).type = data.data["type"];
  Provider.of<UserModel>(context, listen: false).crop = data.data["crop"];
  Provider.of<UserModel>(context, listen: false).phoneNumber =
      data.data["phone"];
  String locData = data.data["location"];

  LatLng loc = new LatLng(
      double.parse(locData.substring(0, locData.indexOf(" "))),
      double.parse(locData.substring(locData.indexOf(" "))));
  Provider.of<UserModel>(context, listen: false).loc = loc;
  String url = await getUrl();
  Provider.of<UserModel>(context, listen: false).url = url;

  Provider.of<UserModel>(context, listen: false).data =
      await loadJson(url, context, user.uid);
}

Future<DocumentSnapshot> getData(String uid) {
  return Firestore.instance.collection("users").document(uid).get();
}

Future<String> getUrl() async {
  var ref =
      await Firestore.instance.collection("data").document("backend").get();
  return ref["ip"];
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
