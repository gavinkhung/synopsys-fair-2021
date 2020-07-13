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
          return Container(child: failed);
        } else {
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

Future<QuerySnapshot> getPrevDisease(String uid) {
  return Firestore.instance
      .collection("users")
      .document(uid)
      .collection("image_diseases")
      .getDocuments();
}
