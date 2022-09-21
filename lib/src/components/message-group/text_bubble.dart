import 'dart:ui';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/components/measure_size.dart';
import 'package:robin_flutter/src/components/message-group/message_options.dart';
import 'package:robin_flutter/src/components/message-group/message_reactions.dart';
import 'package:robin_flutter/src/components/robin_audio_player.dart';
import 'package:robin_flutter/src/components/robin_video_thumbnail.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/views/robin_image_preview.dart';

class TextBubble extends StatefulWidget {
  final RobinMessage message;
  final bool lastInSeries;
  final bool firstInSeries;
  final double maxWidth;
  final bool? loadUrl;

  const TextBubble({
    Key? key,
    required this.message,
    required this.lastInSeries,
    required this.firstInSeries,
    required this.maxWidth,
    this.loadUrl,
  }) : super(key: key);

  @override
  State<TextBubble> createState() => _TextBubbleState();
}

class _TextBubbleState extends State<TextBubble> {
  final RobinController rc = Get.find();

  final RxBool fileDownloading = false.obs;

  final RxBool fileDownloaded = false.obs;

  final Map filePath = {};

  double imageWidth = 0;

  double textWidth = 0;

  void downloadFile(String url) async {
    fileDownloading.value = true;
    try {
      String filename = fileName(widget.message.link);
      http.Client client = http.Client();
      var req = await client.get(Uri.parse(url));
      var bytes = req.bodyBytes;
      String dir = (await getApplicationDocumentsDirectory()).path;
      filePath['path'] = '$dir/$filename';
      File file = File(filePath['path']);
      await file.writeAsBytes(bytes);
      fileDownloading.value = false;
      fileDownloaded.value = true;
    } catch (e) {
      fileDownloading.value = false;
    }
  }

  void showOverLay(BuildContext context) {
    var overlay = Overlay.of(context)!;
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    if (offset.dy - 47 < 50) {
      offset = Offset(offset.dx, 100);
    }
    if (size.height < 250) {
      if (offset.dy + size.height + 250 > MediaQuery.of(context).size.height) {
        offset = Offset(
            offset.dx,
            offset.dy -
                (offset.dy +
                    size.height +
                    300 -
                    MediaQuery.of(context).size.height));
      }
    }
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: entry?.remove,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Material(
              color: black.withOpacity(0.2),
              child: Transform.translate(
                offset: Offset(
                  widget.message.sentByMe ? -10 : offset.dx,
                  offset.dy - 49,
                ),
                child: Column(
                  crossAxisAlignment: widget.message.sentByMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MessageReactions(
                      message: widget.message,
                      entry: entry,
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      width: size.width,
                      child: TextBubble(
                        message: widget.message,
                        lastInSeries: widget.lastInSeries,
                        firstInSeries: widget.firstInSeries,
                        maxWidth: widget.maxWidth,
                        loadUrl: false,
                      ),
                    ),
                    const SizedBox(height: 5),
                    MessageOptions(
                      message: widget.message,
                      entry: entry,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    setState(() {
      // _optionsHeight = null;
    });
  }

  Widget renderReply() {
    RobinMessage? reply = rc.conversationMessages[widget.message.replyTo];
    if (reply == null) {
      return const SizedBox(
        width: 0,
      );
    }
    if (widget.message.isAttachment &&
        fileType(
              path: widget.message.link,
            ) ==
            'image') {
      return Container(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 3),
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 49,
              color: const Color(0XFF9999BC),
            ),
            Container(
              color: const Color(0XFFF5F7FC),
              width: imageWidth - 9 < 0 ? null : imageWidth - 9,
              padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    reply.sentByMe ? 'You' : reply.senderName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0XFF9999BC),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    constraints: imageWidth - 6 < 0
                        ? null
                        : reply.isAttachment
                            ? BoxConstraints(maxWidth: imageWidth - 21)
                            : BoxConstraints(maxWidth: imageWidth - 21),
                    child: Text(
                      !reply.isAttachment
                          ? reply.text
                          : fileType(
                                    path: reply.link,
                                  ) ==
                                  'image'
                              ? "Photo"
                              : fileName(reply.link),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0XFF101010),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (widget.message.isAttachment &&
        (fileType(
                  path: widget.message.link,
                ) ==
                'image' ||
            fileType(
                  path: widget.message.link,
                ) ==
                'video')) {
      return Container(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 3),
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 49,
              color: const Color(0XFF9999BC),
            ),
            Container(
              color: const Color(0XFFF5F7FC),
              width: imageWidth - 9 < 0 ? null : imageWidth - 9,
              padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    reply.sentByMe ? 'You' : reply.senderName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0XFF9999BC),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    constraints: imageWidth - 6 < 0
                        ? null
                        : reply.isAttachment
                            ? BoxConstraints(maxWidth: imageWidth - 21)
                            : BoxConstraints(maxWidth: imageWidth - 21),
                    child: Text(
                      !reply.isAttachment
                          ? reply.text
                          : fileType(
                                    path: reply.link,
                                  ) ==
                                  'image'
                              ? "Photo"
                              : !reply.isAttachment
                                  ? reply.text
                                  : fileType(
                                            path: reply.link,
                                          ) ==
                                          'video'
                                      ? "Video"
                                      : fileName(reply.link),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0XFF101010),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: !widget.message.isAttachment
          ? const EdgeInsets.fromLTRB(15, 12, 15, 0)
          : const EdgeInsets.fromLTRB(6, 10, 6, 3),
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 49,
            color: const Color(0XFF9999BC),
          ),
          Container(
            color: const Color(0XFFF5F7FC),
            width: widget.message.isAttachment
                ? widget.maxWidth - 17
                : textWidth > 35
                    ? textWidth - 35
                    : null,
            padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  reply.sentByMe ? 'You' : reply.senderName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0XFF9999BC),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth - 32),
                  child: Text(
                    !reply.isAttachment
                        ? reply.text
                        : fileType(
                                  path: reply.link,
                                ) ==
                                'image'
                            ? "Photo"
                            : fileType(
                                      path: reply.link,
                                    ) ==
                                    'video'
                                ? "Video"
                                : fileType(
                                          path: reply.link,
                                        ) ==
                                        'audio'
                                    ? "Audio"
                                    : fileName(reply.link),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0XFF101010),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.loadUrl == null || widget.loadUrl!
          ? () {
              HapticFeedback.selectionClick();
              showOverLay(context);
            }
          : null,
      onLongPress: widget.loadUrl == null || widget.loadUrl!
          ? () {
              HapticFeedback.selectionClick();
              showOverLay(context);
            }
          : null,
      child: MeasureSize(
        onChange: (size) {
          if (mounted) {
            setState(() {
              textWidth = size.width;
            });
          }
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            minWidth: 55,
          ),
          decoration: BoxDecoration(
            color: widget.message.sentByMe
                ? const Color(0XFFDBE4FF)
                : const Color(0XFFFFFFFF),
            borderRadius: widget.lastInSeries && widget.message.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(0),
                  )
                : widget.lastInSeries && !widget.message.sentByMe
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(8),
                      )
                    : BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.message.isForwarded
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: widget.message.isAttachment &&
                                  fileType(path: widget.message.link) != 'audio'
                              ? 5
                              : 12,
                          top: 5),
                      child: SvgPicture.asset(
                        'assets/icons/forwarded.svg',
                        package: 'robin_flutter',
                        width: 60,
                      ),
                    )
                  : const SizedBox(),
              widget.firstInSeries
                  ? Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 10, top: 7),
                      child: Text(
                        widget.message.senderName,
                        style: TextStyle(
                          fontSize: 14,
                          color: rc.userColors[widget.message.senderToken] ??
                              const Color(0XFF7A7A7A),
                        ),
                      ),
                    )
                  : const SizedBox(),
              renderReply(),
              widget.message.isAttachment
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          fileType(path: widget.message.link) == 'image' &&
                                  widget.message.isGroupOfAttachments
                              ? MeasureSize(
                                  onChange: (size) {
                                    if (mounted) {
                                      setState(() {
                                        imageWidth = size.width;
                                      });
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    ((MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.75) -
                                                            33) /
                                                        2,
                                                maxHeight: 104,
                                              ),
                                              child: GestureDetector(
                                                onTap: !rc
                                                        .selectMessageView.value
                                                    ? () {
                                                        showGeneralDialog(
                                                          barrierLabel: "Label",
                                                          barrierDismissible:
                                                              false,
                                                          barrierColor: Colors
                                                              .transparent,
                                                          transitionDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          context: context,
                                                          pageBuilder: (context,
                                                              anim1, anim2) {
                                                            return ImagePreview(
                                                              attachment: widget
                                                                  .message
                                                                  .groupLinks[0],
                                                              isLocal: !widget
                                                                          .message
                                                                          .groupDelivered[
                                                                      0] &&
                                                                  widget
                                                                      .message
                                                                      .groupFilePaths[
                                                                          0]
                                                                      .isNotEmpty,
                                                            );
                                                          },
                                                          transitionBuilder:
                                                              (context,
                                                                  anim1,
                                                                  anim2,
                                                                  child) {
                                                            return SlideTransition(
                                                              position: Tween(
                                                                      begin:
                                                                          const Offset(
                                                                              0,
                                                                              1),
                                                                      end: const Offset(
                                                                          0, 0))
                                                                  .animate(
                                                                      anim1),
                                                              child: child,
                                                            );
                                                          },
                                                        );
                                                      }
                                                    : null,
                                                child: Hero(
                                                  tag: widget
                                                      .message.groupLinks[0],
                                                  child:
                                                      widget.message
                                                              .groupDelivered[0]
                                                          ? CachedNetworkImage(
                                                              imageUrl: widget
                                                                  .message
                                                                  .groupLinks[0],
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                if (widget.message
                                                                            .groupJustSent[
                                                                        0] &&
                                                                    widget
                                                                        .message
                                                                        .groupFilePaths[
                                                                            0]
                                                                        .isNotEmpty) {
                                                                  return Image
                                                                      .file(
                                                                    File(widget
                                                                        .message
                                                                        .groupFilePaths[0]),
                                                                    width: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    height: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                }
                                                                return const Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          10,
                                                                          15,
                                                                          10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 26,
                                                                    height: 26,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            24,
                                                                        height:
                                                                            24,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2.5,
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(
                                                                            Color(0XFF15AE73),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            )
                                                          : Image.file(
                                                              File(widget
                                                                  .message
                                                                  .groupLinks[0]),
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    ((MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.75) -
                                                            33) /
                                                        2,
                                                maxHeight: 104,
                                              ),
                                              child: GestureDetector(
                                                onTap: !rc
                                                        .selectMessageView.value
                                                    ? () {
                                                        showGeneralDialog(
                                                          barrierLabel: "Label",
                                                          barrierDismissible:
                                                              false,
                                                          barrierColor: Colors
                                                              .transparent,
                                                          transitionDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          context: context,
                                                          pageBuilder: (context,
                                                              anim1, anim2) {
                                                            return ImagePreview(
                                                              attachment: widget
                                                                  .message
                                                                  .groupLinks[1],
                                                              isLocal: !widget
                                                                          .message
                                                                          .groupDelivered[
                                                                      1] &&
                                                                  widget
                                                                      .message
                                                                      .groupFilePaths[
                                                                          1]
                                                                      .isNotEmpty,
                                                            );
                                                          },
                                                          transitionBuilder:
                                                              (context,
                                                                  anim1,
                                                                  anim2,
                                                                  child) {
                                                            return SlideTransition(
                                                              position: Tween(
                                                                      begin:
                                                                          const Offset(
                                                                              0,
                                                                              1),
                                                                      end: const Offset(
                                                                          0, 0))
                                                                  .animate(
                                                                      anim1),
                                                              child: child,
                                                            );
                                                          },
                                                        );
                                                      }
                                                    : null,
                                                child: Hero(
                                                  tag: widget
                                                      .message.groupLinks[1],
                                                  child:
                                                      widget.message
                                                              .groupDelivered[1]
                                                          ? CachedNetworkImage(
                                                              imageUrl: widget
                                                                  .message
                                                                  .groupLinks[1],
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                if (widget.message
                                                                            .groupJustSent[
                                                                        1] &&
                                                                    widget
                                                                        .message
                                                                        .groupFilePaths[
                                                                            1]
                                                                        .isNotEmpty) {
                                                                  return Image
                                                                      .file(
                                                                    File(widget
                                                                        .message
                                                                        .groupFilePaths[1]),
                                                                    width: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    height: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                }
                                                                return const Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          10,
                                                                          15,
                                                                          10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 26,
                                                                    height: 26,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            24,
                                                                        height:
                                                                            24,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2.5,
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(
                                                                            Color(0XFF15AE73),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            )
                                                          : Image.file(
                                                              File(widget
                                                                  .message
                                                                  .groupLinks[1]),
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    ((MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.75) -
                                                            33) /
                                                        2,
                                                maxHeight: 104,
                                              ),
                                              child: GestureDetector(
                                                onTap: !rc
                                                        .selectMessageView.value
                                                    ? () {
                                                        showGeneralDialog(
                                                          barrierLabel: "Label",
                                                          barrierDismissible:
                                                              false,
                                                          barrierColor: Colors
                                                              .transparent,
                                                          transitionDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          context: context,
                                                          pageBuilder: (context,
                                                              anim1, anim2) {
                                                            return ImagePreview(
                                                              attachment: widget
                                                                  .message
                                                                  .groupLinks[2],
                                                              isLocal: !widget
                                                                          .message
                                                                          .groupDelivered[
                                                                      2] &&
                                                                  widget
                                                                      .message
                                                                      .groupFilePaths[
                                                                          2]
                                                                      .isNotEmpty,
                                                            );
                                                          },
                                                          transitionBuilder:
                                                              (context,
                                                                  anim1,
                                                                  anim2,
                                                                  child) {
                                                            return SlideTransition(
                                                              position: Tween(
                                                                      begin:
                                                                          const Offset(
                                                                              0,
                                                                              1),
                                                                      end: const Offset(
                                                                          0, 0))
                                                                  .animate(
                                                                      anim1),
                                                              child: child,
                                                            );
                                                          },
                                                        );
                                                      }
                                                    : null,
                                                child: Hero(
                                                  tag: widget
                                                      .message.groupLinks[2],
                                                  child:
                                                      widget.message
                                                              .groupDelivered[2]
                                                          ? CachedNetworkImage(
                                                              imageUrl: widget
                                                                  .message
                                                                  .groupLinks[2],
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                if (widget.message
                                                                            .groupJustSent[
                                                                        2] &&
                                                                    widget
                                                                        .message
                                                                        .groupFilePaths[
                                                                            2]
                                                                        .isNotEmpty) {
                                                                  return Image
                                                                      .file(
                                                                    File(widget
                                                                        .message
                                                                        .groupFilePaths[2]),
                                                                    width: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    height: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                }
                                                                return const Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          10,
                                                                          15,
                                                                          10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 26,
                                                                    height: 26,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            24,
                                                                        height:
                                                                            24,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2.5,
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(
                                                                            Color(0XFF15AE73),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            )
                                                          : Image.file(
                                                              File(widget
                                                                  .message
                                                                  .groupLinks[2]),
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    ((MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.75) -
                                                            33) /
                                                        2,
                                                maxHeight: 104,
                                              ),
                                              child: GestureDetector(
                                                onTap: !rc
                                                        .selectMessageView.value
                                                    ? () {
                                                        showGeneralDialog(
                                                          barrierLabel: "Label",
                                                          barrierDismissible:
                                                              false,
                                                          barrierColor: Colors
                                                              .transparent,
                                                          transitionDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                          context: context,
                                                          pageBuilder: (context,
                                                              anim1, anim2) {
                                                            return ImagePreview(
                                                              attachment: widget
                                                                  .message
                                                                  .groupLinks[3],
                                                              isLocal: !widget
                                                                          .message
                                                                          .groupDelivered[
                                                                      3] &&
                                                                  widget
                                                                      .message
                                                                      .groupFilePaths[
                                                                          3]
                                                                      .isNotEmpty,
                                                            );
                                                          },
                                                          transitionBuilder:
                                                              (context,
                                                                  anim1,
                                                                  anim2,
                                                                  child) {
                                                            return SlideTransition(
                                                              position: Tween(
                                                                      begin:
                                                                          const Offset(
                                                                              0,
                                                                              1),
                                                                      end: const Offset(
                                                                          0, 0))
                                                                  .animate(
                                                                      anim1),
                                                              child: child,
                                                            );
                                                          },
                                                        );
                                                      }
                                                    : null,
                                                child: Hero(
                                                  tag: widget
                                                      .message.groupLinks[3],
                                                  child:
                                                      widget.message
                                                              .groupDelivered[3]
                                                          ? CachedNetworkImage(
                                                              imageUrl: widget
                                                                  .message
                                                                  .groupLinks[3],
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                if (widget.message
                                                                            .groupJustSent[
                                                                        3] &&
                                                                    widget
                                                                        .message
                                                                        .groupFilePaths[
                                                                            3]
                                                                        .isNotEmpty) {
                                                                  return Image
                                                                      .file(
                                                                    File(widget
                                                                        .message
                                                                        .groupFilePaths[3]),
                                                                    width: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    height: ((MediaQuery.of(context).size.width *
                                                                                0.75) -
                                                                            50) /
                                                                        2,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  );
                                                                }
                                                                return const Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          10,
                                                                          10,
                                                                          15,
                                                                          10),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 26,
                                                                    height: 26,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            24,
                                                                        height:
                                                                            24,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2.5,
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(
                                                                            Color(0XFF15AE73),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                            )
                                                          : Image.file(
                                                              File(widget
                                                                  .message
                                                                  .groupLinks[3]),
                                                              width: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              height: ((MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.75) -
                                                                      33) /
                                                                  2,
                                                              fit: BoxFit.cover,
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : fileType(path: widget.message.link) == 'image'
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.75) -
                                              91,
                                          maxHeight: 211,
                                        ),
                                        child: GestureDetector(
                                          onTap: !rc.selectMessageView.value
                                              ? () async{
                                                  await showGeneralDialog(
                                                    barrierLabel: "Label",
                                                    barrierDismissible: false,
                                                    barrierColor:
                                                        Colors.transparent,
                                                    transitionDuration:
                                                        const Duration(
                                                            milliseconds: 200),
                                                    context: context,
                                                    pageBuilder: (context,
                                                        anim1, anim2) {
                                                      return ImagePreview(
                                                        attachment:
                                                            widget.message.link,
                                                        isLocal: !widget.message
                                                                .delivered &&
                                                            widget
                                                                .message
                                                                .filePath
                                                                .isNotEmpty,
                                                      );
                                                    },
                                                    transitionBuilder: (context,
                                                        anim1, anim2, child) {
                                                      return SlideTransition(
                                                        position: Tween(
                                                                begin:
                                                                    const Offset(
                                                                        0, 1),
                                                                end:
                                                                    const Offset(
                                                                        0, 0))
                                                            .animate(anim1),
                                                        child: child,
                                                      );
                                                    },
                                                  );
                                                }
                                              : null,
                                          child: Hero(
                                            tag: widget.message.link,
                                            child: MeasureSize(
                                              onChange: (size) {
                                                if (mounted) {
                                                  setState(() {
                                                    imageWidth = size.width;
                                                  });
                                                }
                                              },
                                              child: widget.message.delivered
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          widget.message.link,
                                                      fit: BoxFit.fitWidth,
                                                      placeholder:
                                                          (context, url) {
                                                        if (widget.message
                                                                .justSent &&
                                                            widget
                                                                .message
                                                                .filePath
                                                                .isNotEmpty) {
                                                          return Image.file(
                                                            File(widget.message
                                                                .filePath),
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          );
                                                        }
                                                        return const Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(10, 10,
                                                                  15, 10),
                                                          child: SizedBox(
                                                            width: 26,
                                                            height: 26,
                                                            child: Center(
                                                              child: SizedBox(
                                                                width: 24,
                                                                height: 24,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2.5,
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation<
                                                                          Color>(
                                                                    Color(
                                                                        0XFF15AE73),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    )
                                                  : Image.file(
                                                      File(widget.message.link),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : fileType(path: widget.message.link) ==
                                          'video'
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            constraints: BoxConstraints(
                                              maxWidth: (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.75) -
                                                  91,
                                            ),
                                            child: RobinVideoThumbnail(
                                              shouldPlay: true,
                                              isDelivered:
                                                  widget.message.delivered,
                                              path: widget.message.link,
                                            ),
                                          ),
                                        )
                                      : fileType(path: widget.message.link) ==
                                              'audio'
                                          ? RobinAudioPlayer(
                                              key: Key(widget.message.id),
                                              url: widget.message.link,
                                              conversationId:
                                                  widget.message.conversationId,
                                            )
                                          : Obx(
                                              () => InkWell(
                                                onTap: () {
                                                  if (fileDownloaded.value) {
                                                    OpenFile.open(
                                                        filePath['path']);
                                                  } else {
                                                    if (!fileDownloading
                                                        .value) {
                                                      downloadFile(
                                                          widget.message.link);
                                                    }
                                                  }
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0XFFF5F7FC),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                10, 15, 10, 15),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/fileTypes/${fileType(path: widget.message.link)}.png',
                                                              package:
                                                                  'robin_flutter',
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              width: 34,
                                                              height: 40,
                                                            ),
                                                            const SizedBox(
                                                              width: 7,
                                                            ),
                                                            Expanded(
                                                              flex: 10000,
                                                              child: Text(
                                                                fileName(widget
                                                                    .message
                                                                    .link),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 15,
                                                                  color: Color(
                                                                      0XFF000000),
                                                                ),
                                                              ),
                                                            ),
                                                            const Spacer(
                                                              flex: 1,
                                                            ),
                                                            fileDownloaded.value
                                                                ? Container()
                                                                : !widget
                                                                        .message
                                                                        .delivered
                                                                    ? Container()
                                                                    : SizedBox(
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            20,
                                                                        child: fileDownloading.value
                                                                            ? const SizedBox(
                                                                                width: 20,
                                                                                height: 20,
                                                                                child: CircularProgressIndicator(
                                                                                  strokeWidth: 2.5,
                                                                                  valueColor: AlwaysStoppedAnimation(
                                                                                    green,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Center(
                                                                                child: SvgPicture.asset(
                                                                                  'assets/icons/export.svg',
                                                                                  package: 'robin_flutter',
                                                                                  width: 20,
                                                                                  height: 20,
                                                                                ),
                                                                              ),
                                                                      ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                          const SizedBox(
                            height: 5,
                          ),
                          switchToCol(
                                  widget.maxWidth, widget.message.text.length)
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            (MediaQuery.of(context).size.width *
                                                    0.75) -
                                                50,
                                      ),
                                      child: formatText(widget.message.text,
                                          truncate: widget.loadUrl != null &&
                                                  !widget.loadUrl!
                                              ? true
                                              : false),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          dateFormat
                                              .format(widget.message.timestamp),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0XFF7A7A7A),
                                          ),
                                        ),
                                        widget.message.sentByMe
                                            ? !widget.message.delivered
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: Image.asset(
                                                      'assets/images/delayed.png',
                                                      package: 'robin_flutter',
                                                      width: 14,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 10,
                                                    child: SvgPicture.asset(
                                                      !widget.message.isRead ||
                                                              rc.currentConversation
                                                                  .value.isGroup!
                                                          ? 'assets/icons/delivered.svg'
                                                          : 'assets/icons/read_receipt.svg',
                                                      package: 'robin_flutter',
                                                      width: 18,
                                                      height: 18,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                            : Container(),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            (MediaQuery.of(context).size.width *
                                                    0.75) -
                                                50,
                                      ),
                                      child: formatText(widget.message.text,
                                          truncate: widget.loadUrl != null &&
                                                  !widget.loadUrl!
                                              ? true
                                              : false),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          dateFormat
                                              .format(widget.message.timestamp),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0XFF7A7A7A),
                                          ),
                                        ),
                                        widget.message.sentByMe
                                            ? !widget.message.delivered
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: Image.asset(
                                                      'assets/images/delayed.png',
                                                      package: 'robin_flutter',
                                                      width: 14,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 10,
                                                    child: SvgPicture.asset(
                                                      !widget.message.isRead ||
                                                              rc.currentConversation
                                                                  .value.isGroup!
                                                          ? 'assets/icons/delivered.svg'
                                                          : 'assets/icons/read_receipt.svg',
                                                      package: 'robin_flutter',
                                                      width: 18,
                                                      height: 18,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                            : Container(),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          const SizedBox(
                            height: 3,
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.loadUrl ?? true
                              ? getURLPreview(widget.message.text)
                              : Container(),
                          switchToCol(
                                  widget.maxWidth, widget.message.text.length)
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            (MediaQuery.of(context).size.width *
                                                    0.75) -
                                                50,
                                      ),
                                      child: formatText(widget.message.text,
                                          truncate: widget.loadUrl != null &&
                                                  !widget.loadUrl!
                                              ? true
                                              : false),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          dateFormat
                                              .format(widget.message.timestamp),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0XFF7A7A7A),
                                          ),
                                        ),
                                        widget.message.sentByMe
                                            ? !widget.message.delivered
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: Image.asset(
                                                      'assets/images/delayed.png',
                                                      package: 'robin_flutter',
                                                      width: 14,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 10,
                                                    child: SvgPicture.asset(
                                                      !widget.message.isRead ||
                                                              rc.currentConversation
                                                                  .value.isGroup!
                                                          ? 'assets/icons/delivered.svg'
                                                          : 'assets/icons/read_receipt.svg',
                                                      package: 'robin_flutter',
                                                      width: 18,
                                                      height: 18,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                            : Container(),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            (MediaQuery.of(context).size.width *
                                                    0.75) -
                                                50,
                                      ),
                                      child: formatText(widget.message.text,
                                          truncate: widget.loadUrl != null &&
                                                  !widget.loadUrl!
                                              ? true
                                              : false),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          dateFormat
                                              .format(widget.message.timestamp),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0XFF7A7A7A),
                                          ),
                                        ),
                                        widget.message.sentByMe
                                            ? !widget.message.delivered
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: Image.asset(
                                                      'assets/images/delayed.png',
                                                      package: 'robin_flutter',
                                                      width: 14,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 10,
                                                    child: SvgPicture.asset(
                                                      !widget.message.isRead ||
                                                              rc.currentConversation
                                                                  .value.isGroup!
                                                          ? 'assets/icons/delivered.svg'
                                                          : 'assets/icons/read_receipt.svg',
                                                      package: 'robin_flutter',
                                                      width: 18,
                                                      height: 18,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                            : Container(),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
