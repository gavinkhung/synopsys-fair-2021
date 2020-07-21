import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/screens/onboard/onboard.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/location.dart';
import 'package:provider/provider.dart';

class Auth extends StatefulWidget {
  bool error = false;
  bool check = false;

  Auth(this.error, this.check);

  @override
  _Auth createState() => _Auth(this.error, this.check);
}

class _Auth extends State<Auth> {
  bool error = false;
  bool check = false;
  String code = "+91";
  final phoneController = TextEditingController();
  Color myGreen = Color.fromRGBO(24, 165, 123, 1);

  _Auth(this.error, this.check);

  @override
  void initState() {
    if (error) {
      _getThingsOnStartup().then((value) {});
    }
    getLocation().then((value) {
      Provider.of<UserModel>(context, listen: false).loc =
          LatLng(value.latitude, value.longitude);
    });
    super.initState();
    if (!check) {
      Future.delayed(Duration.zero, () {
        pickLang(context, "").then((value) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Auth(false, true)));
        });
      });
    }
  }

  @override
  void dispose() {
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
      },
    );
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
                            color: Colors.white,
                          ),
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
                        topRight: Radius.circular(50),
                      ),
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
                                  bottom: _logSpace / 2,
                                ),
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
                                                fontSize: 100, color: myGreen),
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
                                          TextInputType.phone,
                                        ),
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
                                                              "SignUp"]["4"],
                                                        ),
                                                        content: Text(
                                                          DemoLocalizations.of(
                                                                      context)
                                                                  .vals[
                                                              "SignUp"]["5"],
                                                        ),
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
            child: new Column(
              children: [
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
              ],
            ),
          ),
        ),
      ),
    );
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
        },
      );
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
      Map<String, dynamic> map = {
        'phone': this.phoneController.text,
        'lang': DemoLocalizations.of(context).locale.languageCode
      };
      Provider.of<UserModel>(context, listen: false).uid = uid;
      setData(map, 0, context);
      analytics.logSignUp(signUpMethod: "auth");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Onboard(
            uid,
            true,
            this.code + phoneController.text,
            Provider.of<UserModel>(context, listen: false).url,
            Provider.of<UserModel>(context, listen: false).loc,
          ),
        ),
      );
    }
  }
}
