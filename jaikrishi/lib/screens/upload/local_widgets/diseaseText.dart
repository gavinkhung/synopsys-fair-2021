import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/text.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:leaf_problem_detection/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'dart:convert';

import '../uploader.dart';

// Widget diseaseText(BuildContext context, String _response) {
//   _response = _response.trim();
//   if (_response == "Healthy Crop") _response = "Healthy";
//   Map data = Provider.of<UserModel>(context, listen: false).data[_response];

//   return Expanded(
//       child: Center(
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//         _response != "This is not rice" &&
//                 _response != "Image is unclear. Please try again" &&
//                 _response != "
//                 Healthy Crop" &&
//                 _response != "PaddyField"
//             ? buildDiseaseReport(context, _response, data)
//             : Text(
//                 data["Disease"],
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//               ),
//         _response != "This is not rice" &&
//                 _response != "Image is unclear. Please try again" &&
//                 _response != "Healthy" &&
//                 _response != "PaddyField"
//             ? infoButton(context, data)
//             : Container(
//                 height: 0,
//               ),
//         shareButton(
//             context,
//             "JaiKrishi " +
//                 texts["DiseaseDetection"]["8"] +
//                 data["Disease"] +
//                 texts["DiseaseDetection"]["9"] +
//                 " www.jaikrishi.com")
//       ])));
// }

Widget diseaseTextHardCode(BuildContext context, String res) {
  // _response = _response.trim();
  // if (_response == "Healthy Crop") _response = "Healthy";
  // Map data = Provider.of<UserModel>(context, listen: false).data[_response];
  Map map = jsonDecode(res);
  String weather = map["weather_disease"]
      .toString()
      .substring(1, map["weather_disease"].toString().length - 1);
  int lcc = int.parse(map["lcc_chart"].toString());
  if (map["image_disease_classification"] == "bacterial_leaf_blight") {
    map = {
      "Disease": "Bacterial Leaf Blight",
      "Step 1":
          "Spray Streptomycin sulphate + Tetracycline combination 300 g + Copper oxychloride 1.25kg/ha. If necessary repeat 15 days later.",
      "Step 2": "Drain the field if in vegetative stage",
      "Step 3": "Leave the field dry for 3-4 days",
      "Link": "https://youtu.be/C44FxCu7ubo",
      "Image": "https://m.farms.com/Portals/0/bacterial-leaf-blight-300-1_1.png"
    };
  } else if (map["image_disease_classification"] == "leaf_smut") {
    map = {
      "Disease": "LeafSmut",
      "Step 1":
          "2 times spray of hexaconazole @ 1.0ml/ litre water at 7 days interval",
      "Step 2": "",
      "Step 3": "",
      "Link": "https://youtu.be/zxbcXWJ6cTA",
      "Image":
          "https://www.lsuagcenter.com/~/media/system/9/4/a/e/94ae4909bab82f9b5def7eabc3bb6983/falsesmut4.jpg"
    };
  } else {
    map = {
      "Disease": "Brown Spot",
      "Step 1":
          "Apply PotashSpray Propiconazole@1.0 gm or Chlorothalonil@2.0 gm per litre of water or Tricyclazole 18% + Manocozeb 62% WP 1000- 1250 gm per Hectare and repeat after 10-12 days if symptoms persist",
      "Step 2": "",
      "Step 3": "",
      "Link": "https://youtu.be/AxFCqZFwDQo",
      "Image":
          "https://www.indogulfbioag.com/Rice-Protect-Kits/images/brown-spot-big.jpg"
    };
  }
  return Expanded(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildDiseaseReportHardCode(context, map["Disease"], lcc, weather),
          infoButtonHardCode(context, map),
          shareButtonHardCode(
            context,
            "JaiKrishi",
          ),
        ],
      ),
    ),
  );
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

Text buildDiseaseReportHardCode(
    BuildContext context, String disease, int lcc, String weather) {
  String text =
      "Detected: " + disease + " in your crop.\n" + "LCC: " + lcc.toString();
  // "If the color is over level 3 it is
  // recommended to add 25 kg of Nitrogen and ha-1 (if needed cover with urea) per
  // season."
  if (lcc > 3) {
    text += ". Add 25 kg nitrogen to your crop.";
  }
  if (weather.length > 0) {
    text += "\n Weather Diseases: " + weather;
  } else {
    text += "\n Weather Diseases: None";
  }
  return Text(
    text,
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
