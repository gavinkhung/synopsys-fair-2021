import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:leaf_problem_detection/models/user_model.dart';
import 'package:provider/provider.dart';

Future<File> imgSrc(ImageSource source) {
  return ImagePicker.pickImage(source: source);
}

Future<File> cropImg(String path) {
  return ImageCropper.cropImage(
    sourcePath: path,
  );
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

Widget imageType(BuildContext context, String type) {
  String image =
      Provider.of<UserModel>(context, listen: false).data[type]["Image"];
  Image img;
  if (image.indexOf("h") == 0) {
    img = Image.network(
        "https://i1.wp.com/agfax.com/wp-content/uploads/rice-blast-leaf-lesions-lsu.jpg?fit=600%2C400&ssl=1",
        scale: 2);
  } else {
    String info = image.substring(image.indexOf(",") + 1);
    img = Image.memory(base64.decode(info), scale: 2);
  }

  return img;
}
