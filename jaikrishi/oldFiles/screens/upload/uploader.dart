import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:leaf_problem_detection/main.dart';
import 'package:leaf_problem_detection/screens/upload/upload.dart';
import 'dart:convert';
import 'dart:math';
import 'package:image/image.dart' as img;

class Uploader extends StatefulWidget {
  final File file;
  final String url;
  final String phone;

  Uploader({Key key, this.file, this.url, this.phone}) : super(key: key);

  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  String response = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<File> getCompressedImage(
    File _imageFile,
  ) async {
    var dilation = sqrt(100000 / _imageFile.lengthSync());
    img.Image image = img.decodeImage(_imageFile.readAsBytesSync());
    img.Image result = img.copyResize(image,
        width: (dilation * image.width).round(),
        height: (dilation * image.height).round());

    _imageFile = new File(_imageFile.path);
    _imageFile.writeAsBytesSync(img.encodeJpg(result));
    return _imageFile;
  }

  Future<File> compress(File _imageFile) async {
    if (_imageFile.lengthSync() < 100000) {
      return _imageFile;
    } else {
      _imageFile = await getCompressedImage(_imageFile);
      return _imageFile;
    }
  }

  Future<String> _startUploadToAPI(String path, String url) async {
    if (user != null) {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['uid'] = widget.phone;
      request.headers["Content-Type"] = "multipart/form-data";
      request.files.add(await http.MultipartFile.fromPath('image', path));
      var res = await request.send();
      var response = await res.stream.bytesToString();
      return response;
    }
    return "";
  }

  _getCurrentUser() async {
    user = await _auth.currentUser();
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
      //onPressed: _startUploadToFirebase,

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
          res = await _startUploadToAPI(path, widget.url);
        } catch (e) {
          res = e.toString();
        }
        // Map valueMap = json.decode(res);
        String resp = res;
        Navigator.pop(c);
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Upload(resp, widget.file, widget.phone, widget.url)),
        );
      },
    );
  }
}
