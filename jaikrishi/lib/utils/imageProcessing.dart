import 'dart:io';
import 'dart:math';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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
