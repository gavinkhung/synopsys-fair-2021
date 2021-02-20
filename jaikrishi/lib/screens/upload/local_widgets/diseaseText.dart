import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/text.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';

import '../uploader.dart';

Widget diseaseText(BuildContext context, String _response) {
  _response = _response.trim();
  if (_response == "Healthy Crop") _response = "Healthy";
  Map data = Provider.of<UserModel>(context, listen: false).data[_response];

  return Expanded(
      child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
        _response != "This is not rice" &&
                _response != "Image is unclear. Please try again" &&
                _response != "Healthy Crop" &&
                _response != "PaddyField"
            ? buildDiseaseReport(context, _response, data)
            : Text(
                data["Disease"],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
        _response != "This is not rice" &&
                _response != "Image is unclear. Please try again" &&
                _response != "Healthy" &&
                _response != "PaddyField"
            ? infoButton(context, data)
            : Container(
                height: 0,
              ),
        shareButton(
            context,
            "JaiKrishi " +
                texts["DiseaseDetection"]["8"] +
                data["Disease"] +
                texts["DiseaseDetection"]["9"] +
                " www.jaikrishi.com")
      ])));
}

Text buildDiseaseReport(BuildContext context, String resp, Map data) {
  if (resp == null) {
    return Text("");
  }

  return Text(
    texts["DetectRice"]["2"] + data["Disease"],
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  );
}

Widget detectionButtons(BuildContext context, File image) {
  return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        padding: EdgeInsets.only(right: 40),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(196, 243, 220, 1),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Uploader(
                    file: image,
                  )),
            ]),
          ],
        ),
      ));
}
