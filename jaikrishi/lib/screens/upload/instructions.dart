import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/main.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Instructions extends StatefulWidget {
  Map data;

  Instructions(this.data);
  _instructions createState() => _instructions(this.data);
}

class _instructions extends State<Instructions> {
  Map data;
  List<Widget> steps;

  _instructions(this.data);

  YoutubePlayerController _controller;

  initState() {
    super.initState();

    data["Link"] != ""
        ? _controller = YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(data["Link"]),
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          )
        : null;
  }

  List<Widget> getSteps(context, player) {
    List<bool> steps = [false, false, false];
    List<Widget> widgets = new List<Widget>();
    if (data["Step 1"] != "") {
      steps[0] = true;
    }

    if (data["Step 2"] != "") {
      steps[1] = true;
    }

    if (data["Step 3"] != "") {
      steps[2] = true;
    }

    for (var i = 0; i < steps.length; i++) {
      if (steps[i]) {
        widgets.add(IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                  padding: EdgeInsets.all(20),
                  //height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width,
                  color: Color.fromRGBO(196, 243, 220, 1),
                  child: Column(
                    children: [
                      Expanded(
                          child: Center(
                        child: Text(
                            (i + 1).toString() +
                                ". " +
                                data["Step " + (i + 1).toString() + ""],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                      )),
                    ],
                  )),
            ),
          ),
        ));
      }
    }

    player != null ? widgets.add(getYoutubeCard(context, player)) : null;
    return widgets;
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: _controller != null
            ? YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueGrey,
                ),
                builder: (context, player) => Container(
                    //padding: EdgeInsets.all(30),
                    height: MediaQuery.of(context).size.height * 2,
                    width: MediaQuery.of(context).size.width,
                    color: Color.fromRGBO(24, 165, 123, 1),
                    child: CupertinoScrollbar(
                        child: ListView(padding: EdgeInsets.zero, children: [
                      Column(children: [
                        Container(
                          color: Colors.white,
                          padding:
                              EdgeInsets.only(left: 10, right: 20, top: 20),
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
                                      child: data == null
                                          ? Text(DemoLocalizations.of(context)
                                              .vals["Instructions"]["2"])
                                          : Text(data["Disease"],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.w600))))
                            ],
                          ),
                        ),
                        Container(
                            child: Column(
                          children: getSteps(context, player),
                        ))
                      ])
                    ]))))
            : Container(
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
                                  child: data == null
                                      ? Text(DemoLocalizations.of(context)
                                          .vals["Instructions"]["2"])
                                      : Text(data["Disease"],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600))))
                        ],
                      ),
                    ),
                    Container(
                        child: Column(
                      children: getSteps(context, null),
                    ))
                  ])
                ]))));
  }

  Widget getYoutubeCard(context, player) {
    return Container(
      padding: EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            color: Color.fromRGBO(196, 243, 220, 1),
            child: Column(
              children: [
                Text(DemoLocalizations.of(context).vals["Instructions"]["1"],
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                Expanded(
                  child: player,
                ),
              ],
            )),
      ),
    );
  }
}
