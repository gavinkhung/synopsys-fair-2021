import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';

import 'package:leaf_problem_detection/utils/files.dart';
import 'package:leaf_problem_detection/utils/imageProcessing.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:provider/provider.dart';

class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  String response = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      icon: Icon(
        Icons.cloud_upload,
        color: Color.fromRGBO(24, 165, 123, 1),
      ),
      label: Text(
        DemoLocalizations.of(context).vals["DetectRice"]["1"],
        style: TextStyle(color: Color.fromRGBO(24, 165, 123, 1), fontSize: 17),
      ),
      onPressed: () async {
        BuildContext c;
        showDialog<void>(
          context: context, // user must tap button!
          builder: (BuildContext context) {
            c = context;
            return CupertinoAlertDialog(
              title: LinearProgressIndicator(),
            );
          },
        );
        String path = "";
        await compress(widget.file).then((value) {
          path = value.path;
        });
        var res = "";
        try {
          String url = Provider.of<UserModel>(context, listen: false).url +
              "/upload?uid=" +
              Provider.of<UserModel>(context, listen: false).uid +
              "&crop=" +
              Provider.of<UserModel>(context, listen: false).crop;
          res = await startUploadToAPI(
              Provider.of<UserModel>(context, listen: false).uid, path, url);
        } catch (e) {
          res = e.toString();
        }
        // Map valueMap = json.decode(res);
        String resp = res;
        Navigator.pop(c);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Upload(widget.file, resp)),
        );
      },
    );
  }
}
