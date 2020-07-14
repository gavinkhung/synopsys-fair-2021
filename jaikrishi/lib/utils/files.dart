import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> localPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<void> setupLocalData(String url, String local, String uid) async {
  var temp2 = localPath();
  String path = await temp2;
  File data = File('$path/data.json');
  String json = await getData(url, local, uid);
  data.writeAsString(json);
}

Future<String> getData(String url, String local, String uid) async {
  String path = url.toString() +
      "/diseases?loc=" +
      local.toString() +
      "&uid=" +
      uid.toString();
  var request = await http.post(path);
  return request.body;
}

Future<Map> loadJson(String url, BuildContext context, String uid) async {
  await setupLocalData(
      url, DemoLocalizations.of(context).locale.countryCode, uid);
  final directory = await getApplicationDocumentsDirectory();
  final file = File(directory.path + '/data.json');
  String data = file.readAsStringSync();
  Map temp = jsonDecode(data);
  return temp;
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
