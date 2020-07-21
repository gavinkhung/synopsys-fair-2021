import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'dart:async';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/card.dart';
import 'package:provider/provider.dart';

import 'local_widgets/widgets.dart';

class Detection extends StatefulWidget {
  Detection();
  _detection createState() => _detection();
}

class _detection extends State<Detection> {
  List<Widget> history;
  String _uid;

  _detection();
  initState() {
    super.initState();
    _uid = Provider.of<UserModel>(context, listen: false).uid;
  }

  Future<List<Widget>> getHist(context) async {
    List<Widget> widgets = new List<Widget>();
    dynamic qs = await getPrevDisease(_uid);
    var docs = qs.documents;
    docs.sort((a, b) {
      var aDT = DateTime.parse(a.data["time"].replaceAll("/", "-") + "Z");
      var bDT = DateTime.parse(b.data["time"].replaceAll("/", "-") + "Z");
      return bDT.compareTo(aDT);
    });
    for (dynamic i in docs) {
      DateTime date =
          DateTime.parse(i.data["time"].replaceAll("/", "-") + " Z");
      bool status = "checked" == i.data["status"];
      String type = i.data["type"];
      String ref = i.data["reference"];
      if (type == "This is not rice" ||
          type == "Image is unclear. Please try again" ||
          type == "Please try again" ||
          type == "Please send an image of Rice!" ||
          type == "Healthy" ||
          type == "Healthy Crop" ||
          i.data["type"] == "PaddyField") continue;

      widgets.add(card(
          context,
          IntrinsicHeight(
              child: jsonPrevDiseaseCard(
                  type,
                  date,
                  ref,
                  i.documentID,
                  _uid,
                  status,
                  yesNoButton(true, i.documentID),
                  yesNoButton(false, i.documentID),
                  context))));
    }
    if (widgets.length == 0) {
      widgets.add(card(
          context,
          Text(
              DemoLocalizations.of(context).vals["prevDetections"]
                  ["noDetected"],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))));
    }
    return widgets;
  }

  FlatButton yesNoButton(bool yes, String id) {
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

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
        //padding: EdgeInsets.all(30),
        height: MediaQuery.of(context).size.height * 2,
        width: MediaQuery.of(context).size.width,
        color: Color.fromRGBO(24, 165, 123, 1),
        child: CupertinoScrollbar(
            child: ListView(padding: EdgeInsets.zero, children: [
          Column(children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 10, right: 20, top: 20),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    iconSize: 30.0,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                      child: Center(
                          child: Text(
                              DemoLocalizations.of(context)
                                  .vals["prevDetections"]["detected"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600))))
                ],
              ),
            ),
            Container(
                child: FutureBuilder<List<Widget>>(
              future: getHist(context),
              builder: (context, data) {
                if (data.hasData) {
                  return Column(
                    children: data.data,
                  );
                } else {
                  return card(
                      context, Center(child: CircularProgressIndicator()));
                }
              },
            ))
          ])
        ])));
  }
}
