import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/text.dart';
import 'dart:async';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/card.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'local_widgets/widgets.dart';

class Notifications extends StatefulWidget {
  Notifications();
  _notifications createState() => _notifications();
}

class _notifications extends State<Notifications> {
  List<Widget> history;
  String _uid;
  YoutubePlayerController _controller;

  initState() {
    super.initState();
    _uid = Provider.of<UserModel>(context, listen: false).uid;
  }

  Future<List<Widget>> getHist(context) async {
    try {
      List<Widget> widgets = new List<Widget>();
      dynamic qs = await getPrevNotifs(_uid);
      List<dynamic> docs = qs.documents;
      docs.sort((a, b) {
        var aDT = DateTime.parse(a.data["time"].replaceAll("/", "-") + "Z");
        var bDT = DateTime.parse(b.data["time"].replaceAll("/", "-") + "Z");
        return bDT.compareTo(aDT);
      });
      // print(docs.length);
      // print(docs[0].data["steps"] == docs[1].data["steps"]);
      for (var i in docs) {
        // print(widgets);
        // print(i.data["steps"]["en"]
        //     .toString());
        DateTime dt = DateTime.parse(i["time"] + "Z").toLocal();
        String link = "";

        try {
          // print(i.data["steps"]);
          // print("en");
          // print(i.data["steps"]["en"]);
          // print(i.data["steps"]["hi"]);
          // print(i.data["steps"]
          // ["en"]);
          if (i["steps"] != null && i["steps"]["en"][0]["Link"] != "") {
            link = i["steps"]["en"][0]["Link"];
          } else if (i["data"] != null && i["data"]["Link"] != null)
            link = i["data"]["Link"];
        } catch (e, st) {
          print(e.toString());
          analytics.logEvent(name: "old_notif_error");
          // print(i.data["steps"]
          //         ["en"]
          //     .toString());
          // if (i["steps"] != null && i["steps"][0]["Link"] != "")
          //   link = i["steps"][0]["Link"];
          // else if (i["data"] != null && i["data"]["Link"] != null)
          //   link = i["data"]["Link"];
        }

        // if (i["steps"] != null && i["steps"][0]["Link"] != "") {
        //   link = i["steps"][0]["Link"];
        // } else if (i["data"] != null && i["data"]["Link"] != null)
        //   link = i["data"]["Link"];

        try {
          widgets.add(card(
              context,
              Column(children: [
                notifBody(dt, i.data, context, false),
                link != ""
                    ? YoutubePlayer(
                        controller: YoutubePlayerController(
                          initialVideoId: YoutubePlayer.convertUrlToId(link),
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
        } catch (e) {
          print(e);
        }
      }
      if (widgets.length == 0) {
        widgets.add(
            card(context, Text(texts["prevNotifications"]["noNotifications"])));
      }
      return widgets;
    } catch (e) {
      print(e.toString());
      throw e;
    }
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
                          child: Text(texts["prevNotifications"]["warning"],
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
