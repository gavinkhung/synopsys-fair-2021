import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/screens/upload/instructions.dart';
import 'package:leaf_problem_detection/text.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:share/share.dart';

Widget infoButton(BuildContext context, Map data) {
  return FlatButton.icon(
    icon: Icon(
      Icons.info,
      color: Color.fromRGBO(24, 165, 123, 1),
    ),
    label: Text(
      texts["DetectRice"]["3"],
      style: TextStyle(color: Color.fromRGBO(24, 165, 123, 1), fontSize: 20),
    ),
    onPressed: () {
      Navigator.of(context, rootNavigator: true)
          .push(MaterialPageRoute(builder: (context) => Instructions(data)));
    },
  );
}

Widget seeMore(BuildContext context, Widget next) {
  return GestureDetector(
      child: Text(texts["History"]["seeMore"],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline)),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => next)));
}

Widget shareButton(BuildContext context, String text) {
  return Builder(
    builder: (BuildContext context) {
      return Center(
        child: FlatButton.icon(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.share),
          label: Text(texts["DiseaseDetection"]["10"]),
          onPressed: () {
            analytics.logShare(contentType: null, itemId: null, method: text);
            final RenderBox box = context.findRenderObject();
            Share.share(text,
                sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
          },
        ),
      );
    },
  );
}
