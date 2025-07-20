import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlatformImage extends StatelessWidget {
  final XFile imageFile;
  final double? height;
  final BoxFit? fit;

  const PlatformImage({
    super.key,
    required this.imageFile,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        imageFile.path,
        height: height,
        fit: fit,
      );
    } else {
      return Image.file(
        File(imageFile.path),
        height: height,
        fit: fit,
      );
    }
  }
}
