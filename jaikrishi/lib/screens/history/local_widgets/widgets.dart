import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/text.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/imageProcessing.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

Column jsonPrevDiseaseCard(
    String type,
    DateTime dt,
    String ref,
    String id,
    String uid,
    bool status,
    FlatButton yes,
    FlatButton no,
    BuildContext context) {
  dt = dt.toLocal();
  type = type.trim();
  Map<String, dynamic> data =
      Provider.of<UserModel>(context, listen: false).data[type];
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Wrap(
        children: [
          Text(
            texts["History"]["detected"],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Text(
            data["Disease"],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
      ref != "" && ref != null
          ? Container(
              height: MediaQuery.of(context).size.height < 600 ? 90 : 150,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              child: Image.network(ref))
          : Container(
              height: 0,
            ),
      infoButton(context, data),
      !status ? Divider() : Container(height: 0, width: 0),
      !status
          ? Column(
              children: [
                Text(
                  texts["History"]["work"],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(24, 165, 123, 1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child:
                        Center(child: yesNoButton(context, id, uid, yes, no)))
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
}

Row yesNoButton(BuildContext context, String id, String uid, FlatButton yes,
    FlatButton no) {
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

Future feedbackResponse(BuildContext context, bool yes) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: ListTile(
              title: yes
                  ? Text(texts["History"]["glad"])
                  : Text(texts["History"]["glad"]),
              subtitle: yes ? Text("") : Text(texts["History"]["thankyou"]),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(texts["History"]["ok"]),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ));
}

Widget notifBody(DateTime dt, Map notifs, BuildContext context, bool page) {
  if (notifs["type"] == "date_notif") {
    String step1 = "";
    String step2 = "";
    String step3 = "";
    String days = "";
    try {
      notifs["steps"]["en"][0]["Step 1"] != null &&
              notifs["steps"]["en"][0]["Step 1"] != ""
          ? step1 = "1. " + notifs["steps"]["en"][0]["Step 1"]
          : "";
      notifs["steps"]["en"][0]["Step 2"] != null &&
              notifs["steps"]["en"][0]["Step 2"] != ""
          ? step2 = "2. " + notifs["steps"]["en"][0]["Step 2"]
          : "";
      notifs["steps"]["en"][0]["Step 3"] != null &&
              notifs["steps"]["en"][0]["Step 3"] != ""
          ? step3 = "3. " + notifs["steps"]["en"][0]["Step 3"]
          : "";
      notifs["steps"]["en"][0]["Days"] != null &&
              notifs["steps"]["en"][0]["Days"] != ""
          ? days = notifs["steps"]["en"][0]["Days"]
          : "";
    } catch (e) {
      print(e);
      analytics.logEvent(name: "old_notif_error");
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
    }

    return Column(children: [
      Text(texts["History"]["based"].toString() +
          days.toString() +
          texts["History"]["days"].toString() +
          texts["History"]["recomend"].toString()),
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
                label: Text(texts["DiseaseDetection"]["10"]),
                onPressed: () {
                  final RenderBox box = context.findRenderObject();
                  Share.share(
                      "JaiKrishi" +
                          texts["History"]["warningNotif"] +
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
  } else if (notifs["type"] == "disease_notif") {
    String tp = Provider.of<UserModel>(context, listen: false)
        .data[notifs["disease"]]["Disease"];
    return Column(
      children: [
        Center(
          child: Text(
              texts["History"]["highChance"] + tp + texts["History"]["present"],
              style: TextStyle(fontSize: 20)),
        ),
        imageType(context, notifs['disease']),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Builder(
            builder: (BuildContext context) {
              return Center(
                child: FlatButton.icon(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.share),
                  label: Text(texts["DiseaseDetection"]["10"]),
                  onPressed: () {
                    final RenderBox box = context.findRenderObject();
                    Share.share(
                        "JaiKrishi" +
                            texts["History"]["warns"] +
                            tp +
                            texts["History"]["warningDisease"],
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
  } else if (notifs['type'] == "misc") {
    return Column(
      children: [
        Center(
          child: page
              ? Text(texts["History"]["suggestLink"],
                  style: TextStyle(fontSize: 20))
              : Text(texts["History"]["suggestLinkOnPrev"],
                  style: TextStyle(fontSize: 20)),
        )
      ],
    );
  }
  return Container();
}
