import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    Key? key,
    required this.attachment,
    this.isLocal,
  }) : super(key: key);

  final String attachment;
  final bool? isLocal;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      key: Key(widget.attachment),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Material(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: widget.attachment,
                  child: widget.isLocal != null && widget.isLocal!
                      ? Image.file(
                          File(widget.attachment),
                          fit: BoxFit.contain,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.attachment,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(10),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 15, 10),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0XFF15AE73),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                ),
              ),
              SafeArea(
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6B7491),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
