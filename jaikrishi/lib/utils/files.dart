import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:leaf_problem_detection/models/weather_model.dart';
import 'package:leaf_problem_detection/utils/firebase.dart';
import 'package:leaf_problem_detection/utils/localization.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

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

Future<String> startUploadToAPI(
    String uid, String path, String url, BuildContext context) async {
  // var request = http.MultipartRequest('POST', Uri.parse(url));
  // request.fields['img'] = uid;
  // request.headers["Content-Type"] = "multipart/form-data";
  // request.files.add(await http.MultipartFile.fromPath('image', path));
  // var res = await request.send();
  // var response = await res.stream.bytesToString();
  // return response;
  WeatherModel weather = Provider.of<WeatherModel>(context, listen: false);
  UserModel user = Provider.of<UserModel>(context, listen: false);
  File imgFile = File(path);
  Uint8List bytes = await imgFile.readAsBytes();
  String base64Image = base64Encode(bytes);
  print("img: " + base64Image);
  var url = 'https://example.com/whatsit/create';
  var response = await http.post(url, body: {
    'img': base64Image,
    'temp': weather.temp,
    'maxTemp': weather.maxTemp,
    'minTemp': weather.minTemp,
    'seeding': user.seed,
    'transplant': user.trans,
    'type': user.type,
    'humidity': weather.humidity,
    'loc': weather.loc.toString()
  });

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  return response.body.toString();
}

Future<String> getTextData(String url) async {
  var res = await http.post(url + "/text");
  return res.body;
}
