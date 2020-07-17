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
  _History createState() => _History();
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
                notifBody(dt, notifs[0], context),
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
          } else
            return Center(child: CircularProgressIndicator());
        });
  }
}
