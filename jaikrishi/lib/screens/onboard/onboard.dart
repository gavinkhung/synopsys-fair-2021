import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/screens/home/home.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'dart:async';

import '../../main.dart';

class Onboard extends StatefulWidget {
  String _username = "";
  bool _firstTime = false;
  String _phone = "";
  String _url;
  LatLng userLoc;

  Onboard(
      this._username, this._firstTime, this._phone, this._url, this.userLoc);
  @override
  _Onboard createState() => _Onboard(
      this._username, this._firstTime, this._phone, this._url, this.userLoc);
}

class _Onboard extends State<Onboard> {
  DateTime _seedingDate;
  DateTime _transplantingDate;
  String _url;
  bool _firstTime = false;
  Color buttonGreen = new Color.fromRGBO(2, 90, 70, 1);
  Color myGreen = new Color.fromRGBO(24, 165, 123, 1);
  String _phone = "";
  String _length = "Select Rice Variety";
  int myLen = 0;
  String _crop = "Select Crop";
  bool alreadyCreated = false;
  LatLng userLoc;
  static LatLng currLoc = null;

  @override
  void initState() {
    super.initState();

    // this.requestLocationPermission();
    // getLocation().then((_locationData) {
    //   userLoc = new LatLng(_locationData.latitude, _locationData.longitude);
    // });
  }

  Completer<GoogleMapController> _controller = Completer();

  static LatLng _center = LatLng(20.0, 79.0);
  final PermissionHandler _permissionHandler = PermissionHandler();

  void _onMapCreated(GoogleMapController controller) {
    if (!this.alreadyCreated) {
      _controller.complete(controller);
    }
    this.alreadyCreated = true;
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> requestLocationPermission() async {
    return _requestPermission(PermissionGroup.locationWhenInUse);
  }

  Set<Marker> _markers = {};

  String _username = "";
  _Onboard(
      this._username, this._firstTime, this._phone, this._url, this.userLoc);

  Widget build(BuildContext context) {
    print("Internal: " + _username);
    print("Provider: " + Provider.of<UserModel>(context, listen: false).uid);

    final introScreens = [
      PageViewModel(
        decoration: PageDecoration(
            pageColor: myGreen, contentPadding: EdgeInsets.all(20)),
        titleWidget: Container(
          height: MediaQuery.of(context).size.height / 2.75,
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset("images/lpdlogonobg.png"),
          ),
        ),
        bodyWidget: Column(
          children: [
            AutoSizeText(
                DemoLocalizations.of(context).vals["WelcometoJaikrishi"]["1"],
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 34.0,
                )),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: AutoSizeText(
                  DemoLocalizations.of(context).vals["WelcometoJaikrishi"]["2"],
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: TextStyle(
                      color: Colors.white, fontSize: 18.0, height: 1.2)),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: MediaQuery.of(context).size.height / 12,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: myGreen),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text(DemoLocalizations.of(context)
                            .vals["WelcometoJaikrishi"]["6"]),
                        message: Text(DemoLocalizations.of(context)
                            .vals["WelcometoJaikrishi"]["7"]),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: Text(DemoLocalizations.of(context)
                                .vals["WelcometoJaikrishi"]["8"]),
                            onPressed: () async {
                              try {
                                //await FirebaseAuth.instance.signOut();
                              } catch (e) {
                                print(e);
                              }
                              setState(() {
                                _crop = "Rice";
                                Navigator.pop(context, 'Rice');
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  padding: EdgeInsets.all(10),
                  color: buttonGreen,
                  child: Center(
                    child: AutoSizeText(
                      _crop == "Rice"
                          ? DemoLocalizations.of(context)
                              .vals["WelcometoJaikrishi"]["8"]
                          : DemoLocalizations.of(context)
                              .vals["WelcometoJaikrishi"]["3"],
                      maxFontSize: 20,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      PageViewModel(
        decoration: PageDecoration(
          pageColor: myGreen,
        ),
        titleWidget: Container(
          height: MediaQuery.of(context).size.height / 3.4,
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset("images/lpdlogonobg.png"),
          ),
        ),
        bodyWidget: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                AutoSizeText(
                    DemoLocalizations.of(context).vals["SeedingLocation"]["1"],
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 34.0,
                    )),
                SizedBox(height: 10),
                AutoSizeText(
                    DemoLocalizations.of(context).vals["SeedingLocation"]["2"],
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.2,
                      fontSize: 18.0,
                    )),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 12,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: _seedingDate == null
                                  ? DateTime.now()
                                  : _seedingDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2022))
                          .then((value) {
                        setState(() {
                          _seedingDate = value;
                        });
                      });
                    },
                    padding: EdgeInsets.all(10),
                    color: buttonGreen,
                    child: Center(
                      child: AutoSizeText(
                        _seedingDate == null
                            ? DemoLocalizations.of(context)
                                .vals["SeedingLocation"]["3"]
                            : _seedingDate.toString().substring(
                                0, _seedingDate.toString().indexOf(" ")),
                        maxFontSize: 20,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 12,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: _transplantingDate == null
                                  ? DateTime.now()
                                  : _transplantingDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2022))
                          .then((value) {
                        setState(() {
                          _transplantingDate = value;
                        });
                      });
                    },
                    padding: EdgeInsets.all(10),
                    color: buttonGreen,
                    child: Center(
                      child: AutoSizeText(
                        _transplantingDate == null
                            ? DemoLocalizations.of(context)
                                .vals["SeedingLocation"]["4"]
                            : _transplantingDate.toString().substring(
                                0, _seedingDate.toString().indexOf(" ")),
                        maxFontSize: 20,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            )),
        //image:
      ),
      PageViewModel(
        decoration: PageDecoration(pageColor: myGreen),
        titleWidget: Container(
          height: MediaQuery.of(context).size.height / 3.4,
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset("images/lpdlogonobg.png"),
          ),
        ),
        bodyWidget: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: AutoSizeText(
                    DemoLocalizations.of(context).vals["VarietyLocation"]["1"],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 32.0,
                    )),
              ),
              SizedBox(height: 10),
              Text(DemoLocalizations.of(context).vals["VarietyLocation"]["2"],
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.2,
                    fontSize: 18.0,
                  )),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: MediaQuery.of(context).size.height / 12,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text(DemoLocalizations.of(context)
                            .vals["VarietyLocation"]["10"]),
                        message: Text(DemoLocalizations.of(context)
                            .vals["VarietyLocation"]["11"]),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: Text(DemoLocalizations.of(context)
                                .vals["VarietyLocation"]["12"]),
                            onPressed: () {
                              setState(() {
                                _length = "Short";
                                myLen = 1;
                                Navigator.pop(context, 'Short');
                              });
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text(DemoLocalizations.of(context)
                                .vals["VarietyLocation"]["13"]),
                            onPressed: () {
                              setState(() {
                                _length = "Medium";
                                myLen = 2;
                                Navigator.pop(context, 'Medium');
                              });
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text(DemoLocalizations.of(context)
                                .vals["VarietyLocation"]["14"]),
                            onPressed: () {
                              setState(() {
                                _length = "Long";
                                myLen = 3;
                                Navigator.pop(context, 'Long');
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                  padding: EdgeInsets.all(10),
                  color: buttonGreen,
                  child: Center(
                    child: AutoSizeText(
                      _length == "Short"
                          ? DemoLocalizations.of(context)
                              .vals["VarietyLocation"]["12"]
                          : _length == "Medium"
                              ? DemoLocalizations.of(context)
                                  .vals["VarietyLocation"]["13"]
                              : _length == "Long"
                                  ? DemoLocalizations.of(context)
                                      .vals["VarietyLocation"]["14"]
                                  : DemoLocalizations.of(context)
                                      .vals["VarietyLocation"]["3"],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                      child: AutoSizeText(
                    DemoLocalizations.of(context).vals["VarietyLocation"]["7"],
                    style: TextStyle(color: Colors.white, fontSize: 1000),
                    maxLines: 1,
                  ))),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: MediaQuery.of(context).size.height / 12,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    _markers.clear();
                    _markers.add(new Marker(
                      // This marker id can be anything that uniquely identifies each marker.
                      markerId: MarkerId("hiya"),
                      position: currLoc != null
                          ? currLoc
                          : userLoc != null ? userLoc : _center,
                      infoWindow: InfoWindow(
                        title: DemoLocalizations.of(context)
                            .vals["VarietyLocation"]["15"],
                        snippet: DemoLocalizations.of(context)
                            .vals["VarietyLocation"]["16"],
                      ),
                      draggable: true,
                      onDragEnd: (latlang) {
                        currLoc = latlang;
                      },
                      icon: BitmapDescriptor.defaultMarker,
                    ));

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.check,
                              size: 40,
                              color: Color.fromRGBO(24, 165, 123, 1),
                            ),
                          ),
                          title: Text(DemoLocalizations.of(context)
                              .vals["VarietyLocation"]["6"]),
                          message: Container(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height -
                                        200,
                                    child: GoogleMap(
                                      markers: _markers,
                                      onMapCreated: _onMapCreated,
                                      myLocationEnabled: true,
                                      initialCameraPosition: CameraPosition(
                                        target: currLoc != null
                                            ? currLoc
                                            : userLoc != null
                                                ? userLoc
                                                : _center,
                                        zoom: 5.0,
                                      ),
                                      rotateGesturesEnabled: true,
                                      scrollGesturesEnabled: true,
                                      tiltGesturesEnabled: true,
                                      zoomGesturesEnabled: true,
                                      zoomControlsEnabled: true,
                                      gestureRecognizers: Set()
                                        ..add(
                                          Factory<PanGestureRecognizer>(
                                              () => PanGestureRecognizer()),
                                        )
                                        ..add(
                                          Factory<LongPressGestureRecognizer>(
                                              () =>
                                                  LongPressGestureRecognizer()),
                                        )
                                        ..add(
                                          Factory<ScaleGestureRecognizer>(
                                            () => ScaleGestureRecognizer(),
                                          ),
                                        )
                                        ..add(
                                          Factory<TapGestureRecognizer>(
                                              () => TapGestureRecognizer()),
                                        )
                                        ..add(
                                          Factory<
                                              VerticalDragGestureRecognizer>(
                                            () =>
                                                VerticalDragGestureRecognizer(),
                                          ),
                                        )
                                        ..add(
                                          Factory<
                                              HorizontalDragGestureRecognizer>(
                                            () =>
                                                HorizontalDragGestureRecognizer(),
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  padding: EdgeInsets.all(10),
                  color: buttonGreen,
                  child: Center(
                    child: Center(
                      child: AutoSizeText(
                        DemoLocalizations.of(context).vals["VarietyLocation"]
                            ["4"],
                        maxFontSize: 20,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      body: IntroductionScreen(
        pages: introScreens,
        onDone: () {
          if (_seedingDate == null ||
              _transplantingDate == null ||
              _length == "Select Rice Variety" ||
              _crop == "Select Crop") {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(DemoLocalizations.of(context)
                        .vals["VarietyLocation"]["8"]),
                    content: Text(DemoLocalizations.of(context)
                        .vals["VarietyLocation"]["9"]),
                    actions: <Widget>[
                      FloatingActionButton(
                        child: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          } else {
            if (_firstTime) {
              Firestore.instance
                  .collection('users')
                  .document(_username)
                  .setData({
                'numFollowers': 0,
                'numFollowing': 0,
                'numPosts': 0,
                'location': currLoc == null
                    ? userLoc.latitude.toString() +
                        " " +
                        userLoc.longitude.toString()
                    : currLoc.latitude.toString() +
                        " " +
                        currLoc.longitude.toString(),
                'seed': _seedingDate,
                'trans': _transplantingDate,
                'type': myLen,
                'crop': _crop,
              }, merge: true);
            } else {
              Firestore.instance
                  .collection('users')
                  .document(_username)
                  .updateData({
                'location': currLoc == null
                    ? userLoc.latitude.toString() +
                        " " +
                        userLoc.longitude.toString()
                    : currLoc.latitude.toString() +
                        " " +
                        currLoc.longitude.toString(),
                'seed': _seedingDate,
                'trans': _transplantingDate,
                'type': myLen,
                'crop': _crop
              });
            }
            getCurrUser().then(
              (value) {
                return setVals(context, value);
              },
            ).then(
              (value) {
                print(
                  "TEESSSST: " +
                      Provider.of<UserModel>(context, listen: false)
                          .phoneNumber
                          .toString(),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
            );
            // setVals(
            //   context,
            // ).then();

          }
        },
        onSkip: () {
          if (_firstTime) {
            Firestore.instance.collection('users').document(_username).setData({
              'phone': _phone,
              'numFollowers': 0,
              'numFollowing': 0,
              'numPosts': 0,
              'location': "",
              'seed': null,
              'trans': null,
              'type': 2,
              'crop': ""
            });
          } else {
            Firestore.instance
                .collection('users')
                .document(_username)
                .updateData({
              'location': "",
              'seed': null,
              'trans': null,
              'type': 2,
              'crop': ""
            });
          }
          getCurrUser().then(
            (value) {
              return setVals(context, value);
            },
          ).then(
            (value) {
              print(
                "TEESSSST: " +
                    Provider.of<UserModel>(context, listen: false)
                        .phoneNumber
                        .toString(),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Home(),
                ),
              );
            },
          );
        },
        done: Text(DemoLocalizations.of(context).vals["VarietyLocation"]["5"],
            style: TextStyle(color: Colors.white, fontSize: 20)),
        showSkipButton: true,
        skip: Text(DemoLocalizations.of(context).vals["SeedingLocation"]["5"],
            style: TextStyle(color: Colors.white, fontSize: 20)),
        showNextButton: true,
        next: Text(DemoLocalizations.of(context).vals["SeedingLocation"]["6"],
            style: TextStyle(color: Colors.white, fontSize: 20)),
        dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Colors.white,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0))),
      ),
    );
  }
}
