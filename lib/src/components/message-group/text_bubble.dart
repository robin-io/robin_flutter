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
    if (offset.dy + size.height + 240 > MediaQuery.of(context).size.height) {
      offset = Offset(
          offset.dx,
          offset.dy -
              (offset.dy +
                  size.height +
                  245 -
                  MediaQuery.of(context).size.height));
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0XFFFFFFFF),
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (String reaction in reactions)
                            Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.message.reactions.keys
                                      .contains(reaction)) {
                                    rc.removeReaction(widget.message.id,
                                        widget.message.reactions[reaction]!.id);
                                  } else {
                                    rc.sendReaction(
                                        reaction, widget.message.id);
                                  }
                                  entry?.remove();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.message.reactions.keys
                                            .contains(reaction)
                                        ? robinOrange
                                        : null,
                                  ),
                                  padding: const EdgeInsets.all(9),
                                  child: Image.asset(
                                    'assets/images/reactions/${reactionToText(reaction)}.png',
                                    package: 'robin_flutter',
                                    width: 22,
                                    height: 22,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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
                    Container(
                      width: 195,
                      decoration: BoxDecoration(
                        color: const Color(0XFFFFFFFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              entry?.remove();
                              rc.replyView.value = false;
                              rc.replyMessage = widget.message;
                              rc.replyView.value = true;
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Color(0XFFF4F4F4),
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Reply Message",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFF101010),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SvgPicture.asset(
                                    'assets/icons/reply.svg',
                                    package: 'robin_flutter',
                                    width: 22,
                                    height: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              entry?.remove();
                              rc.selectMessageView.value = true;
                              rc.selectedMessageIds.add(widget.message.id);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Color(0XFFF4F4F4),
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Forward",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFF101010),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SvgPicture.asset(
                                    'assets/icons/forward.svg',
                                    package: 'robin_flutter',
                                    width: 22,
                                    height: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              entry?.remove();
                              rc.selectMessageView.value = true;
                              rc.selectedMessageIds.add(widget.message.id);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Color(0XFFF4F4F4),
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Select Message",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFF101010),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SvgPicture.asset(
                                    'assets/icons/select_messages.svg',
                                    package: 'robin_flutter',
                                    width: 22,
                                    height: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     entry?.remove();
                          //   },
                          //   child: Container(
                          //     decoration: const BoxDecoration(
                          //       border: Border(
                          //         bottom: BorderSide(
                          //           width: 1,
                          //           color: Color(0XFFF4F4F4),
                          //         ),
                          //       ),
                          //     ),
                          //     padding: const EdgeInsets.all(12),
                          //     child: Row(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         const Text(
                          //           "Star Message",
                          //           style: TextStyle(
                          //             fontSize: 14,
                          //             color: Color(0XFF101010),
                          //           ),
                          //         ),
                          //         const SizedBox(width: 10),
                          //         SvgPicture.asset(
                          //           'assets/icons/star.svg',
                          //           package: 'robin_flutter',
                          //           width: 22,
                          //           height: 22,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: () {
                              entry?.remove();
                              rc.selectMessageView.value = true;
                              rc.selectedMessageIds.add(widget.message.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              color: Colors.transparent,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Delete Message",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFF101010),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SvgPicture.asset(
                                    'assets/icons/delete.svg',
                                    package: 'robin_flutter',
                                    width: 22,
                                    height: 22,
                                  ),
                                ],
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
        );
      },
    );
    overlay.insert(entry);
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
              width: imageWidth - 6 < 0 ? null : imageWidth - 6,
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
                      fontSize: 16,
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
                    fontSize: 16,
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          fileType(path: widget.message.link) == 'image'
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          (MediaQuery.of(context).size.width *
                                                  0.75) -
                                              91,
                                      maxHeight: 211,
                                    ),
                                    child: GestureDetector(
                                      onTap: !rc.selectMessageView.value
                                          ? () {
                                              showGeneralDialog(
                                                barrierLabel: "Label",
                                                barrierDismissible: false,
                                                barrierColor:
                                                    Colors.transparent,
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                context: context,
                                                pageBuilder:
                                                    (context, anim1, anim2) {
                                                  return ImagePreview(
                                                    widget.message.link,
                                                  );
                                                },
                                                transitionBuilder: (context,
                                                    anim1, anim2, child) {
                                                  return SlideTransition(
                                                    position: Tween(
                                                            begin: const Offset(
                                                                0, 1),
                                                            end: const Offset(
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
                                          child: CachedNetworkImage(
                                            imageUrl: widget.message.link,
                                            placeholder: (context, url) =>
                                                const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 10, 15, 10),
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Color(0XFF15AE73),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Obx(
                                  () => InkWell(
                                    onTap: () {
                                      if (fileDownloaded.value) {
                                        OpenFile.open(filePath['path']);
                                      } else {
                                        if (!fileDownloading.value) {
                                          downloadFile(widget.message.link);
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0XFFF5F7FC),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 15, 10, 15),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/fileTypes/${fileType(path: widget.message.link)}.png',
                                                  package: 'robin_flutter',
                                                  fit: BoxFit.fitHeight,
                                                  width: 34,
                                                  height: 40,
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Expanded(
                                                  flex: 10000,
                                                  child: Text(
                                                    fileName(
                                                        widget.message.link),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0XFF000000),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(
                                                  flex: 1,
                                                ),
                                                fileDownloaded.value
                                                    ? Container()
                                                    : SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: fileDownloading
                                                                .value
                                                            ? const SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2.5,
                                                                  valueColor:
                                                                      AlwaysStoppedAnimation(
                                                                    green,
                                                                  ),
                                                                ),
                                                              )
                                                            : Center(
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  'assets/icons/export.svg',
                                                                  package:
                                                                      'robin_flutter',
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dateFormat.format(widget.message.timestamp),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0XFF7A7A7A),
                                ),
                              ),
                              widget.message.sentByMe &&
                                      !rc.currentConversation.value.isGroup!
                                  ? SizedBox(
                                      height: 10,
                                      child: SvgPicture.asset(
                                        widget.message.isRead
                                            ? 'assets/icons/read_receipt.svg'
                                            : 'assets/icons/unread_receipt.svg',
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: (MediaQuery.of(context).size.width *
                                          0.75) -
                                      111,
                                ),
                                child: formatText(widget.message.text),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Row(
                                children: [
                                  Text(
                                    dateFormat.format(widget.message.timestamp),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0XFF7A7A7A),
                                    ),
                                  ),
                                  widget.message.sentByMe &&
                                          !rc.currentConversation.value.isGroup!
                                      ? SizedBox(
                                          height: 10,
                                          child: SvgPicture.asset(
                                            widget.message.isRead
                                                ? 'assets/icons/read_receipt.svg'
                                                : 'assets/icons/unread_receipt.svg',
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
