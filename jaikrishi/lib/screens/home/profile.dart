import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/main.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/utils/location.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';

import 'package:intl/intl.dart';

class profile extends StatefulWidget {
  _profile createState() => _profile();
}

class _profile extends State<profile> {
  String _username = "";
  Color myGreen = Color.fromRGBO(24, 165, 123, 1);
  int following = 0, followers = 0, posts = 0;
  String strLocation = "", length = "";
  DateTime seed, trans;
  LatLng location;
  final controller = TextEditingController();
  int times;

 

  @override
  void initState() {
    times = 0;
    super.initState();
    _username = Provider.of<UserModel>(context, listen: false).uid;
    //_signOut();
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
                        child: FlatButton.icon(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.share,
                              color: Color.fromRGBO(196, 243, 220, 1)),
                          label: Text(
                            DemoLocalizations.of(context)
                                .vals["DiseaseDetection"]["10"],
                            style: TextStyle(
                                color: Color.fromRGBO(196, 243, 220, 1)),
                          ),
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
                    buildWeatherCard(context, times),
                    cropInfoCard(),
                  ],
                ))
          ])),
        ),
      ),
    );
  }

  Widget cropInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Color.fromRGBO(196, 243, 220, 1),
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(20),
        child: IntrinsicHeight(child: getUserData()),
      ),
    );
  }

  Column getUserData() {
    UserModel user = Provider.of<UserModel>(context, listen: false);
    String crop = user.crop;
    DateTime seed;
    try {
      seed = user.seed;
    } catch (e) {
      print(e);
    }
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
            ? Text(
                crop == "Rice"
                    ? DemoLocalizations.of(context).vals["FirstPage"]["3"]
                    : DemoLocalizations.of(context).vals["FirstPage"]["3"],
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize:
                      MediaQuery.of(context).size.height < 600 ? 16.5 : 25,
                ))
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
}
