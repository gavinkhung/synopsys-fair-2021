import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

FirebaseAuth _auth = FirebaseAuth.instance;
Firestore _firebaseStore = Firestore.instance;
bool justSignedUp = false;

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
