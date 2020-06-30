import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaf_problem_detection/main.dart';
import 'package:share/share.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class profile extends StatefulWidget {
  String _username = "";
  profile(this._username);
  _profile createState() => _profile(this._username);
}

class _profile extends State<profile> {
  _profile(this._username);
  String _username = "";
  Color myGreen = Color.fromRGBO(24, 165, 123, 1);
  int following = 0, followers = 0, posts = 0;
  String strLocation = "", length = "";
  DateTime seed, trans;
  LatLng location;
  Future<DocumentSnapshot> data;
  final controller = TextEditingController();
  int times;

  Map<dynamic, dynamic> weather;
  String humidity, typeWeather, temp, minTemp, maxTemp, day, id;

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    times = 0;
    super.initState();
    data = Firestore.instance.collection("users").document(_username).get();
    //_signOut();
  }

  Future<Map> getData() async {
    DocumentSnapshot fb =
        await Firestore.instance.collection("users").document(_username).get();
    String lat = "20", long = "79";
    List<String> location = fb.data['location'].toString().split(" ");
    lat = location[0];
    long = location[1];
    String apiKey = await rootBundle.loadString("data/keys.json");
    String weatherKey = jsonDecode(apiKey)["weather"];
    String path = 'http://api.openweathermap.org/data/2.5/weather?lat=' +
        lat.toString() +
        '&lon=' +
        long.toString() +
        '&appid=' +
        weatherKey +
        '&units=metric';
    print(path);
    var request = await http.get(path);
    return json.decode(request.body);
  }

  Container buildWeatherCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color.fromRGBO(196, 243, 220, 1),
              borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.all(20),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FutureBuilder(
                    future: getData(),
                    builder: (context, value) {
                      try {
                        times++;
                        if (value == null) {
                          return Column(
                            children: times == 0
                                ? [
                                    CircularProgressIndicator(
                                      backgroundColor:
                                          Color.fromRGBO(24, 165, 123, 1),
                                    )
                                  ]
                                : [
                                    Center(
                                        child: Text(
                                      DemoLocalizations.of(context)
                                          .vals["FirstPage"]["8"],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17),
                                    ))
                                  ],
                          );
                        } else if (value.hasData) {
                          weather = value.data;

                          if (weather != null) {
                            temp = weather['main']['temp'].round().toString();
                            minTemp =
                                weather['main']['temp_min'].round().toString();
                            maxTemp =
                                weather['main']['temp_max'].round().toString();
                            humidity = weather['main']['humidity'].toString();
                            typeWeather =
                                weather['weather'][0]['main'].toString();
                            day = DateFormat.yMMMEd().format(DateTime.now());
                            id = weather['weather'][0]['icon'].toString();
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            day,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      600
                                                  ? 16.5
                                                  : 25,
                                            ),
                                          ),
                                          Text(
                                            temp + "°C",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      600
                                                  ? 20
                                                  : 30,
                                            ),
                                          ),
                                          Text(
                                            minTemp + "°C/" + maxTemp + "°C",
                                            style: TextStyle(
                                              color: Colors.black38,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      600
                                                  ? 10
                                                  : 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.network(
                                          "http://openweathermap.org/img/wn/" +
                                              id +
                                              "@2x.png",
                                          scale: 1.5),
                                    ],
                                  ),
                                  Divider(
                                      color: Color.fromRGBO(24, 165, 123, 1)),
                                  Wrap(
                                    children: [
                                      Text(
                                        DemoLocalizations.of(context)
                                            .vals["FirstPage"]["1"],
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height <
                                                  600
                                              ? 11.3
                                              : 17,
                                        ),
                                      ),
                                      Text(
                                        typeWeather,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height <
                                                  600
                                              ? 11.3
                                              : 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      Text(
                                        DemoLocalizations.of(context)
                                            .vals["FirstPage"]["2"],
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height <
                                                  600
                                              ? 11.3
                                              : 17,
                                        ),
                                      ),
                                      Text(
                                        humidity + "%",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height <
                                                  600
                                              ? 11.3
                                              : 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: data,
                                    builder: (context, data) {
                                      if (data.hasData) {
                                        List<String> locs;
                                        var coords;
                                        try {
                                          locs =
                                              data.data["location"].split(" ");
                                          coords = new Coordinates(
                                              double.parse(locs[0]),
                                              double.parse(locs[1]));
                                        } catch (Exception) {
                                          return Row(
                                            children: [
                                              Text(
                                                DemoLocalizations.of(context)
                                                    .vals["FirstPage"]["7"],
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .height <
                                                              600
                                                          ? 11.3
                                                          : 17,
                                                ),
                                                softWrap: true,
                                              ),
                                              Text(
                                                " NA",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .height <
                                                              600
                                                          ? 11.3
                                                          : 17,
                                                ),
                                                softWrap: true,
                                              ),
                                            ],
                                          );
                                        }

                                        return FutureBuilder<List<Address>>(
                                            future: Geocoder.local
                                                .findAddressesFromCoordinates(
                                                    coords),
                                            builder: (context, data) {
                                              if (data.hasData) {
                                                return Container(
                                                  child: Wrap(
                                                    children: [
                                                      Text(
                                                        DemoLocalizations.of(
                                                                    context)
                                                                .vals[
                                                            "FirstPage"]["7"],
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height <
                                                                  600
                                                              ? 11.3
                                                              : 17,
                                                        ),
                                                        softWrap: true,
                                                      ),
                                                      Text(
                                                        data.data[0]
                                                            .addressLine,
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height <
                                                                  600
                                                              ? 11.3
                                                              : 17,
                                                        ),
                                                        //softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                            });
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              children: times == 0
                                  ? [
                                      CircularProgressIndicator(
                                        backgroundColor:
                                            Color.fromRGBO(24, 165, 123, 1),
                                      )
                                    ]
                                  : [
                                      Center(
                                        child: Text(
                                          DemoLocalizations.of(context)
                                              .vals["FirstPage"]["8"],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17),
                                        ),
                                      )
                                    ],
                            );
                          }
                        } else {
                          return Column(
                            children: times == 0
                                ? [
                                    CircularProgressIndicator(
                                      backgroundColor:
                                          Color.fromRGBO(24, 165, 123, 1),
                                    )
                                  ]
                                : [
                                    Center(
                                        child: Text(
                                      DemoLocalizations.of(context)
                                          .vals["FirstPage"]["8"],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17),
                                    ))
                                  ],
                          );
                        }
                      } catch (e) {
                        print(e.toString());
                        return Column(
                          children: times == 0
                              ? [
                                  CircularProgressIndicator(
                                    backgroundColor:
                                        Color.fromRGBO(24, 165, 123, 1),
                                  )
                                ]
                              : [
                                  Center(
                                      child: Text(
                                    DemoLocalizations.of(context)
                                        .vals["FirstPage"]["8"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17),
                                  ))
                                ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                                    child: FutureBuilder<DocumentSnapshot>(
                                        future: data,
                                        builder: (context, data) {
                                          if (data.hasData) {
                                            if (data.data["name"] != null)
                                              controller.text =
                                                  data.data["name"];
                                            return Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  8 *
                                                  7,
                                              child: TextField(
                                                controller: controller,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintMaxLines: 1,
                                                  hintText: controller.text ==
                                                          ""
                                                      ? DemoLocalizations.of(
                                                                  context)
                                                              .vals["FirstPage"]
                                                          ["14"]
                                                      : "",
                                                ),
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .height <
                                                                600
                                                            ? 20
                                                            : 30,
                                                    color: Colors.white),
                                                onSubmitted: (String s) {
                                                  _addUsername(controller.text);
                                                },
                                              ),
                                            );
                                          } else {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        FlatButton.icon(
                          icon: Icon(Icons.flip),
                          label: Text("Sign Out"),
                          onPressed: () async {
                            await _signOut();
                          },
                        ),
                      ],
                    ),
                    buildWeatherCard(context),
                    cropInfoCard(),
                  ],
                ))
          ])),
        ),
      ),
    );
  }

  Future<String> getFirestoreFieldFromUser(String key) async {
    String output = "";
    await Firestore.instance
        .collection("users")
        .document(_username)
        .get()
        .then((value) => {output = value.data[key]});
    return output;
  }

  _addUsername(String name) async {
    await Firestore.instance
        .collection("users")
        .document(_username)
        .updateData({"name": name});
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
        child: IntrinsicHeight(
          child: Column(
            children: [
              FutureBuilder(
                future: data,
                builder: (context, data) {
                  if (data.hasData) {
                    String crop = data.data["crop"];
                    DateTime seed;
                    try {
                      seed = data.data["seed"].toDate();
                    } catch (e) {
                      print(e);
                    }
                    DateTime trans;
                    try {
                      trans = data.data["trans"].toDate();
                    } catch (e) {
                      print(e);
                    }
                    int variety = data.data["type"];
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
                                    ? DemoLocalizations.of(context)
                                        .vals["FirstPage"]["3"]
                                    : DemoLocalizations.of(context)
                                        .vals["FirstPage"]["3"],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize:
                                      MediaQuery.of(context).size.height < 600
                                          ? 16.5
                                          : 25,
                                ))
                            : Text("NA",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize:
                                      MediaQuery.of(context).size.height < 600
                                          ? 16.5
                                          : 25,
                                )),
                        Container(
                          child:
                              Divider(color: Color.fromRGBO(24, 165, 123, 1)),
                        ),
                        type != ""
                            ? Row(
                                children: [
                                  Text(
                                    DemoLocalizations.of(context)
                                        .vals["FirstPage"]["4"],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                  Text(
                                    getVariety(type, context),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    DemoLocalizations.of(context)
                                        .vals["FirstPage"]["4"],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                  Text(
                                    "NA",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                ],
                              ),
                        seed != null
                            ? Wrap(
                                children: [
                                  Text(
                                    DemoLocalizations.of(context)
                                        .vals["FirstPage"]["5"],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.yMMMEd().format(seed),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                ],
                              )
                            : Wrap(
                                children: [
                                  Text(
                                    DemoLocalizations.of(context)
                                        .vals["FirstPage"]["5"],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                  Text(
                                    " NA",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                ],
                              ),
                        trans != null
                            ? Wrap(
                                children: [
                                  Text(
                                    DemoLocalizations.of(context)
                                        .vals["FirstPage"]["6"],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.yMMMEd().format(trans),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                ],
                              )
                            : Wrap(
                                children: [
                                  Text(
                                    DemoLocalizations.of(context)
                                        .vals["FirstPage"]["6"],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                  Text(
                                    "NA",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 15
                                              : 20,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
