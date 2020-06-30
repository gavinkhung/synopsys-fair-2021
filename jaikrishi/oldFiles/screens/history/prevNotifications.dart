import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:leaf_problem_detection/screens/history/history.dart';
import 'dart:async';
import 'package:leaf_problem_detection/main.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Notifications extends StatefulWidget {
  String _uid;
  Notifications(this._uid);
  _notifications createState() => _notifications(this._uid);
}

class _notifications extends State<Notifications> {
  List<Widget> history;
  String _uid;
  YoutubePlayerController _controller;

  _notifications(this._uid);
  initState() {
    super.initState();
  }

  Future<List<Widget>> getHist(context) async {
    List<Widget> widgets = new List<Widget>();
    QuerySnapshot qs = await History.getPrevNotifs(_uid);
    var docs = qs.documents;
    docs.sort((a, b) {
      var aDT = DateTime.parse(a.data["time"].replaceAll("/", "-") + "Z");
      var bDT = DateTime.parse(b.data["time"].replaceAll("/", "-") + "Z");
      return bDT.compareTo(aDT);
    });
    for (var i in docs) {
      DateTime dt = DateTime.parse(i["time"] + "Z").toLocal();
      widgets.add(createCard(Column(children: [
        History.notifBody(dt, i, context),
        i["steps"] != null && i["steps"][0]["Link"] != ""
            ? YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId:
                      YoutubePlayer.convertUrlToId(i["steps"][0]["Link"]),
                  flags: YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                  ),
                ),
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueGrey,
                bottomActions: <Widget>[],
              )
            : Container(
                height: 0,
              )
      ])));
    }

    if (widgets.length == 0) {
      widgets.add(createCard(Text(DemoLocalizations.of(context)
          .vals["prevNotifications"]["noNotifications"])));
    }
    return widgets;
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
                                  .vals["prevNotifications"]["warning"],
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
