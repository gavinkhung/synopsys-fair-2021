import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:leaf_problem_detection/models/user_model.dart';

StreamBuilder autoLogin(Widget success, Widget failed) {
  return StreamBuilder(
    stream: FirebaseAuth.instance.onAuthStateChanged,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        FirebaseUser user = snapshot.data;
        if (user == null) {
          return Container(child: failed);
        } else {
          setVals(context, user);
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
}

Future<DocumentSnapshot> getData(String uid) {
  return Firestore.instance.collection("users").document(uid).get();
}
