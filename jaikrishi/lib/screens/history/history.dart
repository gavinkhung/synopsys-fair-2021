import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/screens/history/prevDetections.dart';
import 'package:leaf_problem_detection/screens/history/prevNotifications.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:provider/provider.dart';

import 'local_widgets/widgets.dart';

class History extends StatefulWidget {
  @override
<<<<<<< HEAD
  _History createState() => _History();
=======
  _History createState() => _History(this._uid);
  static Future<QuerySnapshot> getPrevDisease(String _uid) {
    return Firestore.instance
        .collection("users")
        .document(_uid)
        .collection("image_diseases")
        .getDocuments();
  }

  static Future<QuerySnapshot> getPrevNotifs(String _uid) {
    return Firestore.instance
        .collection("users")
        .document(_uid)
        .collection("daily_diseases")
        .getDocuments();
  }

  static FutureBuilder imageType(String type) {
    return FutureBuilder(
        future: History.loadJson(type),
        builder: (context, data) {
          if (data.hasData) {
            String image = data.data["Image"];
            Image img;
            if (image.indexOf("h") == 0) {
              img = Image.network(
                  "https://i1.wp.com/agfax.com/wp-content/uploads/rice-blast-leaf-lesions-lsu.jpg?fit=600%2C400&ssl=1",
                  scale: 2);
            } else {
              String info = image.substring(image.indexOf(",") + 1);
              img = Image.memory(base64.decode(info), scale: 2);
            }

            return img;
          } else {
            return (Center(child: CircularProgressIndicator()));
          }
        });
  }

  static Widget notifBody(
      DateTime dt, DocumentSnapshot notifs, BuildContext context) {
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
      print(days);
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
                            step3 +
                            DemoLocalizations.of(context).vals["FirstPage"]
                                ["9"],
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

    return FutureBuilder(
        future: History.loadJson(notifs["type"]),
        builder: (context, data) {
          if (data.hasData) {
            String tp = data.data["Disease"];
            return Column(
              children: [
                Center(
                  child: Text(
                      DemoLocalizations.of(context).vals["History"]
                              ["highChance"] +
                          tp +
                          DemoLocalizations.of(context).vals["History"]
                              ["present"],
                      style: TextStyle(fontSize: 20)),
                ),
                History.imageType(notifs['type']),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (BuildContext context) {
                          return Center(
                            child: FlatButton.icon(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.share),
                              label: Text(DemoLocalizations.of(context)
                                  .vals["DiseaseDetection"]["10"]),
                              onPressed: () {
                                final RenderBox box =
                                    context.findRenderObject();
                                Share.share(
                                    "JaiKrishi" +
                                        DemoLocalizations.of(context)
                                            .vals["History"]["warns"] +
                                        tp +
                                        DemoLocalizations.of(context)
                                            .vals["History"]["warningDisease"] +
                                        DemoLocalizations.of(context)
                                            .vals["FirstPage"]["9"],
                                    sharePositionOrigin:
                                        box.localToGlobal(Offset.zero) &
                                            box.size);
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
          } else {
            return CircularProgressIndicator();
          }
        });
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
                Upload.createMoreInfoButton(context, data.data),
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
>>>>>>> c6f9db8ba06e6180f5f78d30a7f48dc19186643b
}

class _History extends State<History> {
  Color myGreen = Color.fromRGBO(24, 165, 123, 1);

  String _uid;
  _History();

  initState() {
    _uid = Provider.of<UserModel>(context, listen: false).uid;
  }

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
                                    style: TextStyle(
                                      color: myGreen,
                                      fontSize:
                                          MediaQuery.of(context).size.height >
                                                  600
                                              ? 25
                                              : 20,
                                    ),
                                  ),
                                ),
                              ),
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

  FutureBuilder<dynamic> cardPrevDisease() {
    return FutureBuilder<dynamic>(
        future: getPrevDisease(_uid),
        builder: (context, dt) {
          if (dt.hasData) {
            List<dynamic> docs = dt.data.documents;
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
                      i.data["type"] != "Healthy Crop" &&
                      i.data["type"] != "PaddyField") {
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
                    i.data["type"] != "Healthy Crop" &&
                    i.data["type"] != "PaddyField") {
                  count++;
                }
              }
            } catch (e) {
              print(e.toString());
            }
            return Center(
                child: Column(children: [
              count != 0
                  ? jsonPrevDiseaseCard(
                      type,
                      max,
                      ref,
                      id,
                      _uid,
                      status == "checked",
                      yesNoButton(true, id),
                      yesNoButton(false, id),
                      context)
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
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Detection())))
                  : Text("")
            ]));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget yesNoButton(bool yes, String id) {
    return FlatButton.icon(
        onPressed: () async {
          feedbackResponse(context, yes);
          await updateNotify(_uid, id);
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

  FutureBuilder<dynamic> cardPrevNotifs(String _uid, BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getPrevNotifs(_uid),
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
                notifBody(dt, notifs[0].data, context, true),
                GestureDetector(
                    child: Text(
                        DemoLocalizations.of(context).vals["History"]
                            ["seeMore"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline)),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Notifications())))
              ]);
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
