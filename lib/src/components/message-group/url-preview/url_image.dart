import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/constants.dart';

/// Shows image of URL
class PreviewImage extends StatelessWidget {
  final String? _image;

  const PreviewImage(this._image, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return CachedNetworkImage(
        imageUrl: _image!,
        fit: BoxFit.cover,
        width: 75,
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
          color: black,
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            Container(),
      );
    } else {
      return Container(
        color: Colors.red,
      );
    }
  }
}
