import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/buttons.dart';
import 'package:leaf_problem_detection/widgets/card.dart';
import 'package:provider/provider.dart';

import 'package:leaf_problem_detection/utils/imageProcessing.dart';

import 'package:leaf_problem_detection/screens/upload/uploader.dart';
import 'package:flutter/cupertino.dart';

import 'local_widgets/diseaseText.dart';

class Upload extends StatefulWidget {
  File _imageFile;
  String _response = "";

  Upload(this._imageFile, this._response);

  @override
  _Upload createState() => _Upload(this._imageFile, this._response);
}

class _Upload extends State<Upload> {
  File _imageFile;
  bool drawFirst;
  double _position = 0;
  String _response;
  String _disease = "rice";
  String illness;

  _Upload(this._imageFile, this._response);

  @override
  void initState() {
    if (_imageFile != null && _imageFile.path == "") {
      _imageFile = null;
    }
    // try {
    //   FirebaseAuth.instance.signOut();
    // } catch (e) {
    //   print(e);
    // }
    super.initState();
  }

  void _clear() {
    setState(() {
      _imageFile = null;
      _response = null;
    });
  }

  PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    controller.addListener(() {
      setState(() {
        _position = controller.page;
      });
    });
<<<<<<< HEAD
=======
    Widget getPageOne() {
      if (_response == "Healthy Crop") _response = "Healthy";
      print(_response);
      return Expanded(
          child: Center(
              child: FutureBuilder(
                  future: History.loadJson(_response),
                  builder: (context, data) {
                    if (data.hasData) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _response != "This is not rice" &&
                                    _response !=
                                        "Image is unclear. Please try again" &&
                                    _response != "Healthy Crop"
                                ? buildDiseaseReport(data.data)
                                : Text(
                                    data.data["Disease"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                            _response != "This is not rice" &&
                                    _response !=
                                        "Image is unclear. Please try again" &&
                                    _response != "Healthy"
                                ? Upload.createMoreInfoButton(
                                    context, data.data)
                                : Container(
                                    height: 0,
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
                                      final RenderBox box =
                                          context.findRenderObject();
                                      Share.share(
                                          "JaiKrishi " +
                                              DemoLocalizations.of(context)
                                                      .vals["DiseaseDetection"]
                                                  ["8"] +
                                              data.data["Disease"] +
                                              DemoLocalizations.of(context)
                                                      .vals["DiseaseDetection"]
                                                  ["9"] +
                                              " https://play.google.com/store/apps/details?id=com.jaikrishi.appjaikrishi",
                                          sharePositionOrigin:
                                              box.localToGlobal(Offset.zero) &
                                                  box.size);
                                    },
                                  ),
                                );
                              },
                            ),
                          ]);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  })));
    }
>>>>>>> c6f9db8ba06e6180f5f78d30a7f48dc19186643b

    return Container(
      //padding: EdgeInsets.all(30),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Color.fromRGBO(24, 165, 123, 1),
      child: CupertinoScrollbar(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              child: Column(
                children: [
                  SafeArea(
                    child: ClipRRect(
                      child: Container(
                        color: Colors.white,
                        child: Stack(
                          children: [
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
                                  Center(
                                    child: Text(
                                      DemoLocalizations.of(context)
                                          .vals["DiseaseDetection"]["1"],
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Color.fromRGBO(24, 165, 123, 1),
                                        fontSize:
                                            MediaQuery.of(context).size.height >
                                                    600
                                                ? 25
                                                : 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_imageFile != null) ...[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height / 1.83,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: FileImage(_imageFile))),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 20, right: 20, top: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    196, 243, 220, 1),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: IconButton(
                                              color: Colors.black,
                                              icon: Icon(
                                                Icons.crop,
                                                color: Color.fromRGBO(
                                                    24, 165, 123, 1),
                                              ),
                                              onPressed: () async {
                                                File cropped = await cropImg(
                                                    _imageFile.path);
                                                setState(() {
                                                  _imageFile =
                                                      cropped ?? _imageFile;
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    196, 243, 220, 1),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: IconButton(
                                              color: Colors.black,
                                              icon: Icon(
                                                Icons.refresh,
                                                color: Color.fromRGBO(
                                                    24, 165, 123, 1),
                                              ),
                                              onPressed: _clear,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              detectionButtons(context, _imageFile)
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  _response == null
                      ? Text("")
                      : card(
                          context,
                          IntrinsicHeight(
                            child: Column(
                              children: [
                                diseaseText(context, _response),
                              ],
                            ),
                          )),
                  _imageFile == null
                      ? card(
                          context,
                          buildInstructions(context),
                        )
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future cropSelectoin(BuildContext context, bool check) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title:
            Text(DemoLocalizations.of(context).vals["DiseaseDetection"]["11"]),
        message:
            Text(DemoLocalizations.of(context).vals["DiseaseDetection"]["12"]),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text(DemoLocalizations.of(context).vals["Crops"]["1"]),
            onPressed: () async {
              File selected;
              check
                  ? selected = await imgSrc(ImageSource.camera)
                  : selected = await imgSrc(ImageSource.gallery);
              setState(() {
                _disease = 'rice';
                Provider.of<UserModel>(context, listen: false).crop = "rice";
                Navigator.pop(
                    context, DemoLocalizations.of(context).vals["Crops"]["1"]);

                _imageFile = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildInstructions(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        children: [
          Text(
            DemoLocalizations.of(context).vals["DiseaseDetection"]["2"],
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height > 600 ? 20 : 15),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: Color.fromRGBO(24, 165, 123, 1),
              thickness: 2,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 2),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("1. ",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.height < 600
                              ? 15
                              : 20)),
                  Flexible(
                    child: Text(
                        DemoLocalizations.of(context).vals["DiseaseDetection"]
                            ["3"],
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.of(context).size.height < 600
                                ? 15
                                : 20)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("2. ",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.height < 600
                              ? 15
                              : 20)),
                  Flexible(
                    child: Text(
                        DemoLocalizations.of(context).vals["DiseaseDetection"]
                            ["4"],
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.of(context).size.height < 600
                                ? 15
                                : 20)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("3. ",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.height < 600
                              ? 15
                              : 20)),
                  Flexible(
                    child: Text(
                        DemoLocalizations.of(context).vals["DiseaseDetection"]
                            ["5"],
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.of(context).size.height < 600
                                ? 15
                                : 20)),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height < 600 ? 90 : 150,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                child: Image.network(
                  "https://i1.wp.com/agfax.com/wp-content/uploads/leaf-blast-texas-am-07012014-facebook-600.jpg?fit=600%2C398&ssl=1",
                  scale: 1.5,
                  fit: BoxFit.fill,
                ),
              )
            ]),
          ),
          Container(
            margin: EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color.fromRGBO(24, 165, 123, 1)),
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      cropSelectoin(context, true);
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.photo_camera,
                                color: Colors.white,
                              ),
                              iconSize: 30.0,
                              onPressed: () {
                                cropSelectoin(context, true);
                              }),
                          Text(
                            DemoLocalizations.of(context)
                                .vals["DiseaseDetection"]["6"],
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                VerticalDivider(color: Colors.white),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      cropSelectoin(context, false);
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              icon: Icon(Icons.photo_library,
                                  color: Colors.white),
                              iconSize: 30.0,
                              onPressed: () {
                                cropSelectoin(context, false);
                              }),
                          Text(
                            DemoLocalizations.of(context)
                                .vals["DiseaseDetection"]["7"],
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
