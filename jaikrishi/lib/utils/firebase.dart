import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';

StreamBuilder autoLogin(Widget success, Widget failed) {
  return StreamBuilder(
    stream: FirebaseAuth.instance.onAuthStateChanged,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        FirebaseUser user = snapshot.data;
        if (user == null) {
          return Container(child: success);
        } else {
          return Container(child: failed);
        }
      } else {
        return Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    },
  );
}

Future<QuerySnapshot> getPrevDisease() {
  return Firestore.instance
      .collection("users")
      .document(_phone)
      .collection("image_diseases")
      .getDocuments();
}
