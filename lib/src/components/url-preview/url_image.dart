import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shows image of URL
class PreviewImage extends StatelessWidget {
  final String? _image;
  final Color? _imageLoaderColor;

  const PreviewImage(this._image, this._imageLoaderColor,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_image != null) {
      return CachedNetworkImage(
        imageUrl: _image!,
        fit: BoxFit.cover,
        width: 75,
        errorWidget: (context, url, error) => Icon(
          Icons.error,
          color: _imageLoaderColor,
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            Container(),
      );
    } else {
      return Container(color: Colors.red,);
    }
  }
}
