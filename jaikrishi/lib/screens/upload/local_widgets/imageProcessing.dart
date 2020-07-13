import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future<File> imgSrc(ImageSource source) {
  return ImagePicker.pickImage(source: source);
}

Future<File> cropImg(String path) {
  return ImageCropper.cropImage(
    sourcePath: path,
  );
}
