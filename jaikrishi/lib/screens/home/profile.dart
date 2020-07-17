import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/models/weather_model.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/location.dart';
import 'package:leaf_problem_detection/widgets/card.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class profile extends StatefulWidget {
  _profile createState() => _profile();
}

class _profile extends State<profile> {
  String _username = "";
  Color myGreen = Color.fromRGBO(24, 165, 123, 1);
  DateTime _seeding = null;
  DateTime _transplanting = null;
  BuildContext mainContext = null;
  Completer<GoogleMapController> _controller = Completer();
  bool alreadyCreated = false;
  LatLng userLoc;
  static LatLng currLoc = null;

  static LatLng _center = LatLng(20.0, 79.0);

  final controller = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    if (!this.alreadyCreated) {
      _controller.complete(controller);
    }
    this.alreadyCreated = true;
  }

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _username = Provider.of<UserModel>(context, listen: false).uid;
    userLoc = Provider.of<UserModel>(context, listen: false).loc;
  }

  String getVariety(String type, BuildContext context) {
    if (type == "Short") {
      return DemoLocalizations.of(context).vals['VarietyLocation']['12'];
    } else if (type == "Medium") {
      return DemoLocalizations.of(context).vals['VarietyLocation']['13'];
    } else if (type == "Long") {
      return DemoLocalizations.of(context).vals['VarietyLocation']['14'];
    }
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return Container(
      color: myGreen,
      child: SafeArea(
        child: Container(
          color: Color.fromRGBO(196, 243, 220, 1),
          child: CupertinoScrollbar(
              child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            Container(
              decoration:
                  BoxDecoration(color: Color.fromRGBO(196, 243, 220, 1)),
              //height: MediaQuery.of(context).size.width / 5,
              padding: EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
              child: Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (BuildContext context) {
                      return Center(
                        child: DropdownButton(
                          icon: Icon(Icons.more, color: myGreen),
                          items: [
                            DropdownMenuItem(
                              value: 1,
                              child: IconButton(
                                icon: Icon(Icons.language),
                                tooltip: "Language",
                                onPressed: () async {
                                  await pickLang(
                                      context,
                                      Provider.of<UserModel>(context,
                                              listen: false)
                                          .uid);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => profile()));
                                },
                              ),
                            ),
                            DropdownMenuItem(
                                value: 2,
                                child: IconButton(
                                    icon: Icon(Icons.location_on),
                                    onPressed: () async {
                                      LocationData value =
                                          await getLocation(true);
                                      Provider.of<UserModel>(context,
                                                  listen: false)
                                              .loc =
                                          LatLng(
                                              value.latitude, value.longitude);
                                      await setWeatherData(
                                          Provider.of<UserModel>(context,
                                                  listen: false)
                                              .uid,
                                          context,
                                          value.latitude.toString(),
                                          value.longitude.toString());
                                      await updateUserWeather(
                                          Provider.of<UserModel>(context,
                                                  listen: false)
                                              .uid,
                                          value);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => profile()));
                                    }))
                          ],
                          onChanged: (value) {},
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Container(
                        child: Center(
                      child: AutoSizeText(
                        DemoLocalizations.of(context).vals["FirstPage"]["10"],
                        maxLines: 1,
                        maxFontSize: 25,
                        style: TextStyle(color: myGreen, fontSize: 100),
                      ),
                    )),
                  ),
                  Builder(
                    builder: (BuildContext context) {
                      return Center(
                        child: FlatButton.icon(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.share),
                          label: Text(DemoLocalizations.of(context)
                              .vals["DiseaseDetection"]["10"]),
                          onPressed: () {
                            final RenderBox box = context.findRenderObject();
                            Share.share(
                                DemoLocalizations.of(context).vals["FirstPage"]
                                    ["9"],
                                sharePositionOrigin:
                                    box.localToGlobal(Offset.zero) & box.size);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
                color: myGreen,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 1,
                //height: double.infinity,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            //height: MediaQuery.of(context).size.width / 10,
                            ),
                        Row(
                          children: [
                            Container(
                              // padding: EdgeInsets.all(20),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                      child: showUsername(
                                          Provider.of<UserModel>(context,
                                                  listen: false)
                                              .uid,
                                          controller)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    buildWeatherCard(context),
                    card(context, getUserData()),
                  ],
                ))
          ])),
        ),
      ),
    );
  }

  Column getUserData() {
    UserModel user = Provider.of<UserModel>(context, listen: true);
    String crop = user.crop;
    DateTime seed;

    seed = user.seed;

    DateTime trans;
    try {
      trans = user.trans;
    } catch (e) {
      print(e);
    }
    int variety = user.type;
    String type = "";
    if (variety == 1)
      type = "Short";
    else if (variety == 2)
      type = "Medium";
    else
      type = "Long";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        crop != "" && crop != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    crop == "Rice"
                        ? DemoLocalizations.of(context).vals["FirstPage"]["3"]
                        : DemoLocalizations.of(context).vals["FirstPage"]["3"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 16.5 : 25,
                    ),
                  ),
                  GestureDetector(
                    child: Icon(
                      Icons.edit,
                      color: Colors.black54,
                    ),
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => CupertinoActionSheet(
                          title: Text("What would you like to edit?"),
                          message: Text("Select something to edit"),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              child: Text("Crop"),
                              onPressed: () async {
                                setState(() {
                                  Navigator.pop(
                                    context,
                                  );
                                });
                                showCropPopup();
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text("Date of Seeding"),
                              onPressed: () async {
                                setState(() {
                                  Navigator.pop(
                                    context,
                                  );
                                });
                                showSeedingPopup(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text("Date of Transplanting"),
                              onPressed: () async {
                                setState(() {
                                  Navigator.pop(
                                    context,
                                  );
                                });
                                showTransplantPopup(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text("Variety"),
                              onPressed: () async {
                                setState(() {
                                  Navigator.pop(
                                    context,
                                  );
                                });
                                showVarietyPopup();
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text("Crop Location"),
                              onPressed: () async {
                                setState(() {
                                  Navigator.pop(
                                    context,
                                  );
                                });
                                showLocationPopup();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              )
            : Text("NA",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 16.5 : 25,
                )),
        Container(
          child: Divider(color: Color.fromRGBO(24, 165, 123, 1)),
        ),
        type != ""
            ? Row(
                children: [
                  Text(
                    DemoLocalizations.of(context).vals["FirstPage"]["4"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                  Text(
                    getVariety(type, context),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Text(
                    DemoLocalizations.of(context).vals["FirstPage"]["4"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                  Text(
                    "NA",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                ],
              ),
        seed != null
            ? Wrap(
                children: [
                  Text(
                    DemoLocalizations.of(context).vals["FirstPage"]["5"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMEd().format(seed),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                ],
              )
            : Wrap(
                children: [
                  Text(
                    DemoLocalizations.of(context).vals["FirstPage"]["5"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                  Text(
                    " NA",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                ],
              ),
        trans != null
            ? Wrap(
                children: [
                  Text(
                    DemoLocalizations.of(context).vals["FirstPage"]["6"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                  Text(
                    DateFormat.yMMMEd().format(trans),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                ],
              )
            : Wrap(
                children: [
                  Text(
                    DemoLocalizations.of(context).vals["FirstPage"]["6"],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                  Text(
                    "NA",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize:
                          MediaQuery.of(context).size.height < 600 ? 15 : 20,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  void showCropPopup() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title:
            Text(DemoLocalizations.of(context).vals["WelcometoJaikrishi"]["6"]),
        message:
            Text(DemoLocalizations.of(context).vals["WelcometoJaikrishi"]["7"]),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
                DemoLocalizations.of(context).vals["WelcometoJaikrishi"]["8"]),
            onPressed: () async {
              Map<String, dynamic> map = {"crop": "Rice"};
              updateUser(
                  Provider.of<UserModel>(context, listen: false).uid, map);
              setState(() {
                Navigator.pop(context, 'Ricee');
              });
            },
          ),
        ],
      ),
    );
  }

  void showSeedingPopup(BuildContext context) {
    showDatePicker(
            context: context,
            initialDate: _seeding == null ? DateTime.now() : _seeding,
            firstDate: DateTime(1900),
            lastDate: DateTime(2022))
        .then(
      (value) {
        setState(() {
          _seeding = value;
        });
      },
    ).whenComplete(() {
      if (_seeding != null) {
        Map<String, dynamic> map = {"seed": _seeding};
        updateUser(
          Provider.of<UserModel>(mainContext, listen: false).uid,
          map,
        );
      }
      setState(() {});
      Navigator.pop(context);
    });
  }

  void showTransplantPopup(BuildContext context) {
    showDatePicker(
            context: context,
            initialDate:
                _transplanting == null ? DateTime.now() : _transplanting,
            firstDate: DateTime(1900),
            lastDate: DateTime(2022))
        .then(
      (value) {
        setState(() {
          _transplanting = value;
        });
      },
    ).whenComplete(() {
      if (_transplanting != null) {
        Map<String, dynamic> map = {"trans": _transplanting};
        updateUser(
          Provider.of<UserModel>(mainContext, listen: false).uid,
          map,
        );
      }
      setState(() {});
      Navigator.pop(context);
    });
  }

  void showVarietyPopup() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title:
            Text(DemoLocalizations.of(context).vals["VarietyLocation"]["10"]),
        message:
            Text(DemoLocalizations.of(context).vals["VarietyLocation"]["11"]),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(
                DemoLocalizations.of(context).vals["VarietyLocation"]["12"]),
            onPressed: () {
              setState(() {
                Map<String, dynamic> map = {"type": 1};
                updateUser(
                  Provider.of<UserModel>(mainContext, listen: false).uid,
                  map,
                );
                Navigator.pop(context, 'Short');
              });
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
                DemoLocalizations.of(context).vals["VarietyLocation"]["13"]),
            onPressed: () {
              setState(() {
                Map<String, dynamic> map = {"type": 2};
                updateUser(
                  Provider.of<UserModel>(mainContext, listen: false).uid,
                  map,
                );
                Navigator.pop(context, 'Medium');
              });
            },
          ),
          CupertinoActionSheetAction(
            child: Text(
                DemoLocalizations.of(context).vals["VarietyLocation"]["14"]),
            onPressed: () {
              setState(() {
                Map<String, dynamic> map = {"type": 3};
                updateUser(
                  Provider.of<UserModel>(mainContext, listen: false).uid,
                  map,
                );
                Navigator.pop(context, 'Long');
              });
            },
          )
        ],
      ),
    );
  }

  showLocationPopup() {
    _markers.clear();
    _markers.add(new Marker(
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId("hiya"),
      position: currLoc != null ? currLoc : userLoc != null ? userLoc : _center,
      infoWindow: InfoWindow(
        title: DemoLocalizations.of(context).vals["VarietyLocation"]["15"],
        snippet: DemoLocalizations.of(context).vals["VarietyLocation"]["16"],
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
              Map<String, dynamic> map = {
                'location': currLoc == null
                    ? userLoc.latitude.toString() +
                        " " +
                        userLoc.longitude.toString()
                    : currLoc.latitude.toString() +
                        " " +
                        currLoc.longitude.toString(),
              };
              updateUser(
                Provider.of<UserModel>(mainContext, listen: false).uid,
                map,
              );
              Navigator.pop(context);
            },
            child: Icon(
              Icons.check,
              size: 40,
              color: Color.fromRGBO(24, 165, 123, 1),
            ),
          ),
          title:
              Text(DemoLocalizations.of(context).vals["VarietyLocation"]["6"]),
          message: Container(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: GoogleMap(
                      markers: _markers,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: currLoc != null
                            ? currLoc
                            : userLoc != null ? userLoc : _center,
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
                              () => LongPressGestureRecognizer()),
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
                          Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer(),
                          ),
                        )
                        ..add(
                          Factory<HorizontalDragGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer(),
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
  }
}
