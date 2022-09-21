import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({
    Key? key,
    required this.child,
    required this.path,
    required this.controller,
  }) : super(key: key);

  final Widget child;
  final String path;
  final VideoPlayerController controller;

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.vertical,
      key: Key(widget.path),
      onDismissed: (_) {
        widget.controller.pause();
        widget.controller.seekTo(const Duration(milliseconds: 0));
        Future.delayed(const Duration(milliseconds: 20), (){
          Navigator.of(context).pop();
        });
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Material(
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: Hero(
                    tag: widget.path,
                    child: widget.child,
                  ),
                ),
                SafeArea(
                  child: IconButton(
                    onPressed: () {
                      widget.controller.pause();
                      widget.controller.seekTo(const Duration(milliseconds: 0));
                      Future.delayed(const Duration(milliseconds: 20), (){
                        Navigator.of(context).pop();
                      });
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
      ),
    );
  }
}
