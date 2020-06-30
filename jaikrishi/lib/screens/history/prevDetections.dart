import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaf_problem_detection/screens/history/history.dart';
import 'dart:async';
import 'package:leaf_problem_detection/main.dart';

class Detection extends StatefulWidget {
  String _uid;
  Detection(this._uid);
  _detection createState() => _detection(this._uid);
}

class _detection extends State<Detection> {
  List<Widget> history;
  String _uid;

  _detection(this._uid);
  initState() {
    super.initState();
  }

  Future<List<Widget>> getHist(context) async {
    List<Widget> widgets = new List<Widget>();
    QuerySnapshot qs = await History.getPrevDisease(_uid);
    var docs = qs.documents;
    docs.sort((a, b) {
      var aDT = DateTime.parse(a.data["time"].replaceAll("/", "-") + "Z");
      var bDT = DateTime.parse(b.data["time"].replaceAll("/", "-") + "Z");
      return bDT.compareTo(aDT);
    });
    for (DocumentSnapshot i in docs) {
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
          type == "Healthy Crop") continue;

      widgets.add(createCard(IntrinsicHeight(
          child: History.jsonPrevDiseaseCard(
              type,
              date,
              ref,
              i.documentID,
              _uid,
              status,
              yesNoButton(true, i.documentID),
              yesNoButton(false, i.documentID)))));
    }
    if (widgets.length == 0) {
      widgets.add(createCard(Text(
          DemoLocalizations.of(context).vals["prevDetections"]["noDetected"],
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))));
    }
    return widgets;
  }

  FlatButton yesNoButton(bool yes, String id) {
    return FlatButton.icon(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    content: ListTile(
                      title: yes
                          ? Text(DemoLocalizations.of(context)
                              .vals["prevDetections"]["great"])
                          : Text(DemoLocalizations.of(context)
                              .vals["prevDetections"]["unfortunate"]),
                      subtitle: yes
                          ? Text("")
                          : Text(DemoLocalizations.of(context)
                              .vals["prevDetections"]["thankyou"]),
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

  Container createCard(Widget child) {
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
                  return createCard(Center(child: CircularProgressIndicator()));
                }
              },
            ))
          ])
        ])));
  }
}
