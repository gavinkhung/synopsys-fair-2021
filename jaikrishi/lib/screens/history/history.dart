import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_problem_detection/main.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'package:leaf_problem_detection/screens/history/prevDetections.dart';
import 'package:leaf_problem_detection/screens/history/prevNotifications.dart';
import 'package:leaf_problem_detection/utils/imageProcessing.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/buttons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';

import 'package:share/share.dart';

class History extends StatefulWidget {
  @override
  _History createState() => _History();

  Widget notifBody(DateTime dt, DocumentSnapshot notifs, BuildContext context) {
    if (notifs["type"] == "date_notif") {
      String step1 = "";
      String step2 = "";
      String step3 = "";
      String days = "";
      notifs["steps"][0]["Step 1"] != null && notifs["steps"][0]["Step 1"] != ""
          ? step1 = "1. " + notifs["steps"][0]["Step 1"]
          : "";
      notifs["steps"][0]["Step 2"] != null && notifs["steps"][0]["Step 2"] != ""
          ? step2 = "2. " + notifs["steps"][0]["Step 2"]
          : "";
      notifs["steps"][0]["Step 3"] != null && notifs["steps"][0]["Step 3"] != ""
          ? step3 = "3. " + notifs["steps"][0]["Step 3"]
          : "";
      notifs["steps"][0]["Days"] != null && notifs["steps"][0]["Days"] != ""
          ? days = notifs["steps"][0]["Days"]
          : "";

      return Column(children: [
        Text(DemoLocalizations.of(context).vals["History"]["based"].toString() +
            days.toString() +
            DemoLocalizations.of(context).vals["History"]["days"].toString() +
            DemoLocalizations.of(context)
                .vals["History"]["recomend"]
                .toString()),
        Text(step1),
        Text(step2),
        Text(step3),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                        "JaiKrishi" +
                            DemoLocalizations.of(context).vals["History"]
                                ["warningNotif"] +
                            step1 +
                            " " +
                            step2 +
                            " " +
                            step3,
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                  },
                ),
              );
            },
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                dt.day.toString() +
                    "/" +
                    dt.month.toString() +
                    "/" +
                    dt.year.toString() +
                    " ",
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.w300),
              ))
        ]),
      ]);
    }

    String tp = Provider.of<UserModel>(context, listen: false)
        .data[notifs["type"]]["Disease"];
    return Column(
      children: [
        Center(
          child: Text(
              DemoLocalizations.of(context).vals["History"]["highChance"] +
                  tp +
                  DemoLocalizations.of(context).vals["History"]["present"],
              style: TextStyle(fontSize: 20)),
        ),
        imageType(context, notifs['type']),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                        "JaiKrishi" +
                            DemoLocalizations.of(context).vals["History"]
                                ["warns"] +
                            tp +
                            DemoLocalizations.of(context).vals["History"]
                                ["warningDisease"],
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size);
                  },
                ),
              );
            },
          ),
          Text(
            dt.day.toString() +
                "/" +
                dt.month.toString() +
                "/" +
                dt.year.toString() +
                " ",
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w300),
          )
        ])
      ],
    );
  }

  static FutureBuilder<Map> jsonPrevDiseaseCard(
      String type,
      DateTime dt,
      String ref,
      String id,
      String uid,
      bool status,
      FlatButton yes,
      FlatButton no) {
    dt = dt.toLocal();
    return FutureBuilder(
        future: History.loadJson(type),
        builder: (context, data) {
          if (data.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  children: [
                    Text(
                      DemoLocalizations.of(context).vals["History"]["detected"],
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      data.data["Disease"],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                ref != "" && ref != null
                    ? Container(
                        height:
                            MediaQuery.of(context).size.height < 600 ? 90 : 150,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(10),
                        child: Image.network(ref))
                    : Container(
                        height: 0,
                      ),
                infoButton(context, data.data),
                !status ? Divider() : Container(height: 0, width: 0),
                !status
                    ? Column(
                        children: [
                          Text(
                            DemoLocalizations.of(context).vals["History"]
                                ["work"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(24, 165, 123, 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                  child:
                                      yesNoButton(context, id, uid, yes, no)))
                        ],
                      )
                    : Container(height: 0, width: 0),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        dt.day.toString() +
                            "/" +
                            dt.month.toString() +
                            "/" +
                            dt.year.toString() +
                            " ",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ))
                ]),
              ],
            );
          } else {
            return Text(type,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600));
          }
        });
  }

  static List<String> getTimeDifAndUnits(DateTime max) {
    var timeUnit = "days";
    double sec = getSecondDif(DateTime.now().toUtc(), max);
    var hours = ((sec) / 60 / 60 / 24).round();
    if (hours == 0) {
      hours = ((sec) / 60 / 60).round();
      timeUnit = "hours";
    }
    if (hours == 0) {
      hours = ((sec) / 60).round();
      timeUnit = "minutes";
    }
    return [hours.toString(), timeUnit];
  }

  static double getSecondDif(DateTime fir, DateTime sec) {
    return ((fir.millisecondsSinceEpoch - sec.millisecondsSinceEpoch) / 1000);
  }

  static Future<Map> loadJson(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(directory.path + '/data.json');
    String t = file.readAsStringSync();
    Map temp = jsonDecode(t);
    name = name.trim();
    return temp[name];
  }

  static Row yesNoButton(BuildContext context, String id, String uid,
      FlatButton yes, FlatButton no) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: yes,
        ),
        Container(
          height: MediaQuery.of(context).size.height / 35,
          child: VerticalDivider(
            width: 5,
            color: Colors.white,
            thickness: 2,
          ),
        ),
        Expanded(
          child: no,
        ),
      ],
    );
  }
}

class _History extends State<History> {
  Color myGreen = Color.fromRGBO(24, 165, 123, 1);

  String _uid;
  _History(this._uid);

  initState() {}

  Widget card(Widget child) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Color.fromRGBO(196, 243, 220, 1),
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myGreen,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Color.fromRGBO(24, 165, 123, 1),
        child: CupertinoScrollbar(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SafeArea(
                child: Column(children: [
                  ClipRRect(
                    child: Container(
                      color: Colors.white,
                      child: Stack(children: [
                        SizedBox(
                          height: 0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(196, 243, 220, 1)),
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 15, bottom: 15),
                          child: Column(
                            children: [
                              Container(
                                  child: Center(
                                child: Text(
                                  DemoLocalizations.of(context)
                                      .vals["CropStatus"]["1"],
                                  maxLines: 1,
                                  style:
                                      TextStyle(color: myGreen, fontSize: 100),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                  card(Column(children: [
                    Text(
                      DemoLocalizations.of(context).vals["History"]["warning"],
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height > 600
                              ? 20
                              : 15),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        color: myGreen,
                        thickness: 2,
                      ),
                    ),
                    cardPrevNotifs(_uid, context),
                  ])),
                  card(IntrinsicHeight(
                    child: Column(
                      children: [
                        Text(
                          DemoLocalizations.of(context).vals["CropStatus"]["8"],
                          // "Previous Disease Detections",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height > 600
                                  ? 20
                                  : 15),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            color: myGreen,
                            thickness: 2,
                          ),
                        ),
                        cardPrevDisease(),
                      ],
                    ),
                  )),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<QuerySnapshot> cardPrevDisease() {
    return FutureBuilder<QuerySnapshot>(
        future: History.getPrevDisease(_uid),
        builder: (context, dt) {
          if (dt.hasData) {
            List<DocumentSnapshot> docs = dt.data.documents;
            docs.sort((a, b) {
              var aDT =
                  DateTime.parse(a.data["time"].replaceAll("/", "-") + "Z");
              var bDT =
                  DateTime.parse(b.data["time"].replaceAll("/", "-") + "Z");
              return aDT.compareTo(bDT);
            });

            String temp = "";
            if (docs.length > 0) {
              temp = docs[0].data["time"].replaceAll("/", "-") + " Z";
            } else {
              return Center(
                  child: Text(
                DemoLocalizations.of(context).vals["History"]["noDetect"],
                style: TextStyle(fontSize: 17),
              ));
            }

            DateTime max = DateTime.parse(temp);
            String type = "";
            String ref = "";
            String id;
            int count = 0;
            String status;

            try {
              for (var i in docs) {
                var dateString = i.data["time"].replaceAll("/", "-") + " Z";
                DateTime cur = DateTime.parse(dateString);

                if (max == null ||
                    (cur.isAfter(max)) ||
                    cur.isAtSameMomentAs(max)) {
                  if (i.data["type"] != "This is not rice" &&
                      i.data["type"] != "Image is unclear. Please try again" &&
                      i.data["type"] != "Please try again" &&
                      i.data["type"] != "Please send an image of Rice!" &&
                      i.data["type"] != "Healthy Rice Plant!" &&
                      i.data["type"] != "Healthy" &&
                      i.data["type"] != "Healthy Crop") {
                    type = i.data["type"];
                  } else
                    continue;
                  id = i.documentID;
                  max = cur;
                  status = i.data["status"];
                  ref = i.data["reference"];
                }

                if (i.data["type"] != "This is not rice" &&
                    i.data["type"] != "Image is unclear. Please try again" &&
                    i.data["type"] != "Please try again" &&
                    i.data["type"] != "Please send an image of Rice!" &&
                    i.data["type"] != "Healthy Rice Plant!" &&
                    i.data["type"] != "Healthy" &&
                    i.data["type"] != "Healthy Crop") {
                  count++;
                }
              }
            } catch (e) {
              print(e.toString());
            }
            return Center(
                child: Column(children: [
              count != 0
                  ? History.jsonPrevDiseaseCard(
                      type,
                      max,
                      ref,
                      id,
                      _uid,
                      status == "checked",
                      yesNoButton(true, id),
                      yesNoButton(false, id))
                  : Text(DemoLocalizations.of(context).vals["History"]
                      ["haventDetect"]),
              count != 0
                  ? GestureDetector(
                      child: Text(
                          DemoLocalizations.of(context).vals["History"]
                              ["seeMore"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline)),
                      // onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => Detection(_uid)))
                    )
                  : Text("")
            ]));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  FlatButton yesNoButton(bool yes, String id) {
    return FlatButton.icon(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: ListTile(
                      title: yes
                          ? Text(DemoLocalizations.of(context).vals["History"]
                              ["glad"])
                          : Text(DemoLocalizations.of(context).vals["History"]
                              ["glad"]),
                      subtitle: yes
                          ? Text("")
                          : Text(DemoLocalizations.of(context).vals["History"]
                              ["thankyou"]),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(DemoLocalizations.of(context)
                            .vals["History"]["ok"]),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
          await Firestore.instance
              .collection("users")
              .document(_uid)
              .collection("image_diseases")
              .document(id)
              .updateData({"status": "checked", "works": "yes"});
          setState(() {});
        },
        icon: Icon(
          yes ? Icons.check : Icons.close,
          color: Colors.white,
        ),
        label: yes
            ? Text(DemoLocalizations.of(context).vals["prevDetections"]["yes"],
                style: TextStyle(color: Colors.white, fontSize: 20))
            : Text(
                DemoLocalizations.of(context).vals["prevDetections"]["no"],
                style: TextStyle(color: Colors.white, fontSize: 20),
              ));
  }

  FutureBuilder<QuerySnapshot> cardPrevNotifs(
      String _uid, BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: History.getPrevNotifs(_uid),
        builder: (context, data) {
          if (data.hasData) {
            var notifs = data.data.documents;
            notifs.sort((a, b) {
              var aDT =
                  DateTime.parse(a.data["time"].replaceAll("/", "-") + "Z");
              var bDT =
                  DateTime.parse(b.data["time"].replaceAll("/", "-") + "Z");
              return bDT.compareTo(aDT);
            });
            if (notifs.length == 0) {
              return Center(
                  child: Text(
                DemoLocalizations.of(context).vals["History"]
                    ["noNotifications"],
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.height > 600 ? 20 : 15),
              ));
            } else {
              DateTime dt = DateTime.parse(notifs[0]["time"] + "Z").toLocal();

              return Column(children: [
                History.notifBody(dt, notifs[0], context),
                GestureDetector(
                  child: Text(
                      DemoLocalizations.of(context).vals["History"]["seeMore"],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline)),
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => Notifications(_uid)))
                )
              ]);
            }
          } else
            return Center(child: CircularProgressIndicator());
        });
  }
}
