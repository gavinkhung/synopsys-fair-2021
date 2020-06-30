import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:leaf_problem_detection/screens/onboard/newOnboard.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../main.dart';

class Anonymous_Signin extends StatefulWidget {
  bool error = false;
  String _url;
  LatLng userLoc;

  Anonymous_Signin(this.error, this._url, this.userLoc);

  @override
  _Anonymous_SigninState createState() =>
      _Anonymous_SigninState(this.error, this._url, this.userLoc);
}

class _Anonymous_SigninState extends State<Anonymous_Signin> {
  bool error = false;
  String code = "+91";
  final phoneController = TextEditingController();
  Color myGreen = Color.fromRGBO(24, 165, 123, 1);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _url;
  LatLng userLoc;

  _Anonymous_SigninState(this.error, this._url, this.userLoc);

  @override
  void initState() {
    if (error) {
      _getThingsOnStartup().then((value) {});
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneController.dispose();
    super.dispose();
  }

  Future _getThingsOnStartup() async {
    await Future.delayed(Duration(seconds: 2));
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: DemoLocalizations.of(context).vals["SignUp"]["4"],
            content: DemoLocalizations.of(context).vals["SignUp"]["6"],
            actions: <Widget>[
              FloatingActionButton(
                child: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                  return;
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginPage(),
    );
  }

  Widget _loginPage() {
    double _logSpace = MediaQuery.of(context).size.height / 6;

    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: myGreen,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: (MediaQuery.of(context).size.height -
                                      MediaQuery.of(context).size.height * 0.5 -
                                      90) /
                                  2 -
                              80,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 4.5,
                          width: MediaQuery.of(context).size.width,
                          //color: Colors.black,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image(
                              image: AssetImage("images/lpdlogonobg.png"),
                            ),
                          ),
                          //decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/plant-pot.png"))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "JaiKrishi",
                          style: TextStyle(
                              fontSize: 30,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50)),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.5 + 90,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.white,
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: _logSpace / 3,
                                    right: _logSpace / 3,
                                    top: _logSpace / 2,
                                    bottom: _logSpace / 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        SizedBox(
                                          width: _logSpace / 4,
                                        ),
                                        Expanded(
                                          child: AutoSizeText(
                                            DemoLocalizations.of(context)
                                                .vals["SignUp"]["1"],
                                            style: TextStyle(
                                                fontSize: 100000,
                                                color: myGreen),
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(
                                          width: _logSpace / 4,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: _logSpace / 4,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        field(
                                            DemoLocalizations.of(context)
                                                .vals["SignUp"]["2"],
                                            TextInputType.phone),
                                        SizedBox(
                                          height: _logSpace / 4,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: myGreen),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              _logSpace * 2 / 3,
                                          height: _logSpace / 2,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            onPressed: () {
                                              if (phoneController
                                                  .text.isEmpty) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            DemoLocalizations.of(
                                                                        context)
                                                                    .vals[
                                                                "SignUp"]["4"]),
                                                        content: Text(
                                                            DemoLocalizations.of(
                                                                        context)
                                                                    .vals[
                                                                "SignUp"]["5"]),
                                                        actions: <Widget>[
                                                          FloatingActionButton(
                                                            child: Icon(
                                                                Icons.close),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              return;
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    });
                                              } else {
                                                _verify(context);
                                              }
                                            },
                                            padding:
                                                EdgeInsets.all(_logSpace / 7),
                                            color: myGreen,
                                            child: Center(
                                              child: AutoSizeText(
                                                DemoLocalizations.of(context)
                                                    .vals["SignUp"]["3"],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 50,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget field(String text, TextInputType type) {
    return new Material(
        child: new Container(
            color: Colors.white,
            child: new Container(
              padding: EdgeInsets.only(top: 5),
              child: new Center(
                  child: new Column(children: [
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: text,
                    labelStyle: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 13 : 17,
                    ),
                    prefixText: "",
                    prefixIcon: TextInputType.phone == type
                        ? CountryCodePicker(
                            onChanged: (CountryCode cCode) {
                              code = cCode.toString();
                            },
                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                            initialSelection: 'IN',
                            favorite: [
                              'United States',
                              '+91',
                            ],
                            padding:
                                EdgeInsets.only(left: 10, right: 5, bottom: 1),
                            textStyle: TextStyle(
                                color: myGreen,
                                fontWeight: FontWeight.normal,
                                fontSize: 15),
                          )
                        : null,
                    suffixIcon: type == TextInputType.phone
                        ? Icon(
                            Icons.phone,
                            size: 30,
                            color: myGreen,
                          )
                        : type == TextInputType.text
                            ? Icon(
                                Icons.account_circle,
                                size: 30,
                                color: myGreen,
                              )
                            : Icon(
                                Icons.lock,
                                size: 30,
                                color: myGreen,
                              ),

                    prefix: null,
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: myGreen),
                        borderRadius: new BorderRadius.circular(25.0)),
                    //fillColor: Colors.green

                    focusColor: myGreen,
                    hintText: type == TextInputType.phone
                        ? "0123456789"
                        : type == TextInputType.text ? "JohnDoe" : "",
                    hoverColor: myGreen,
                    counterStyle: TextStyle(color: myGreen),
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return "Email cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  controller: phoneController,
                  keyboardType: TextInputType.text,
                  style: new TextStyle(fontFamily: "Poppins", color: myGreen),
                  obscureText: type == TextInputType.phone
                      ? false
                      : type == TextInputType.text ? false : true,
                ),
              ])),
            )));
  }

  _verify(BuildContext context) async {
    if (phoneController.text.contains("+")) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(DemoLocalizations.of(context).vals["SignUp"]["8"]),
              content: Text(DemoLocalizations.of(context).vals["SignUp"]["7"]),
              actions: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                    return;
                  },
                )
              ],
            );
          });
      return;
    }
    dynamic uid = await signInAnonymous();
    if (uid == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(DemoLocalizations.of(context).vals["SignUp"]["4"]),
              content: Text(DemoLocalizations.of(context).vals["SignUp"]["8"]),
              actions: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                    return;
                  },
                )
              ],
            );
          });
    } else {
      var ref = Firestore.instance.collection('users').document(uid);
      ref.setData({
        'phone': this.phoneController.text,
        'numPosts': 0,
        'numFollowers': 0,
        'numFollowing': 0
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => newOnboard(uid, true,
                this.code + phoneController.text, this._url, this.userLoc)),
      );
    }
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
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInAnonymous() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
