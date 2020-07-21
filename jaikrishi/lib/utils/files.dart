import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Map<String, dynamic> data = null;
Future<String> localPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<void> setupLocalData(String url) async {
  var temp2 = localPath();
  String path = await temp2;
  File data = File('$path/data.json');
  String json = await getData(url);
  data.writeAsString(json);
}

Future<String> getData(String url) async {
  String path = url.toString() + "/newDiseases";
  var request = await http.post(path);
  return request.body;
}

Future<Map> tempJson(String url, BuildContext context) async {
  await setupLocalData(url);
  final directory = await getApplicationDocumentsDirectory();
  final file = File(directory.path + '/data.json');
  String data = file.readAsStringSync();
  Map temp = jsonDecode(data);
  return temp;
}

Future<Map> loadJson(String url, BuildContext context, String lang) async {
  while (true) {
    try {
      if (data == null) {
        data = await tempJson(url, context);
      }
      break;
    } catch (e) {
      analytics.logEvent(
        name: 'load_json_broke',
        parameters: <String, dynamic>{
          'string': data.toString(),
        },
      );
      print(e.toString());
    }
  }

  return data[lang];
}

Future<String> startUploadToAPI(String uid, String path, String url) async {
  var request = http.MultipartRequest('POST', Uri.parse(url));
  request.fields['uid'] = uid;
  request.headers["Content-Type"] = "multipart/form-data";
  request.files.add(await http.MultipartFile.fromPath('image', path));
  var res = await request.send();
  var response = await res.stream.bytesToString();
  return response;
}

Future<String> getTextData(String url) async {
  var res = await http.post(url + "/text");
  return res.body;
}
