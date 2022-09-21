import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

import '../views/robin_video_preview.dart';

class RobinVideoThumbnail extends StatefulWidget {
  const RobinVideoThumbnail({
    Key? key,
    required this.isDelivered,
    required this.path,
    required this.shouldPlay,
  }) : super(key: key);

  final bool? isDelivered;
  final String path;
  final bool shouldPlay;

  @override
  State<RobinVideoThumbnail> createState() => _RobinVideoThumbnailState();
}

class _RobinVideoThumbnailState extends State<RobinVideoThumbnail> {
  late VideoPlayerController _controller;

  bool videoLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isDelivered != null && widget.isDelivered!) {
      _controller = VideoPlayerController.network(widget.path)
        ..initialize().then((_) {
          setState(() {
            videoLoaded = true;
          });
        });
    } else {
      _controller = VideoPlayerController.file(File(widget.path))
        ..initialize().then((_) {
          setState(() {
            videoLoaded = true;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return videoLoaded
        ? GestureDetector(
            onTap: () async {
              final chewieController = ChewieController(
                videoPlayerController: _controller,
                autoPlay: true,
                looping: false,
              );
              await showGeneralDialog(
                barrierLabel: "Label",
                barrierDismissible: false,
                barrierColor: Colors.transparent,
                transitionDuration: const Duration(milliseconds: 200),
                context: context,
                pageBuilder: (context, anim1, anim2) {
                  return VideoPreview(
                    path: widget.path,
                    controller: _controller,
                    child: Chewie(
                      controller: chewieController,
                    ),
                  );
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position: Tween(
                            begin: const Offset(0, 1), end: const Offset(0, 0))
                        .animate(anim1),
                    child: child,
                  );
                },
              );
              _controller.pause();
              _controller.seekTo(const Duration(milliseconds: 0));
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                children: [
                  Center(
                    child: VideoPlayer(
                      _controller,
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[400],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 32,
                        color: Colors.black54,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container(
            width: 300,
            height: 200,
            color: Colors.grey[400],
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(green),
              ),
            ),
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
