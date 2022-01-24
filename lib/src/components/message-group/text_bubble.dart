import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

class TextBubble extends StatelessWidget {
  final RobinMessage message;
  final bool lastInSeries;
  final bool firstInSeries;
  final double maxWidth;
  final bool? loadUrl;

  TextBubble({
    Key? key,
    required this.message,
    required this.lastInSeries,
    required this.firstInSeries,
    required this.maxWidth,
    this.loadUrl,
  }) : super(key: key);

  final RobinController rc = Get.find();

  final RxBool fileDownloading = false.obs;
  final RxBool fileDownloaded = false.obs;

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
                  message.sentByMe ? -10 : offset.dx,
                  offset.dy - 49,
                ),
                child: Column(
                  crossAxisAlignment: message.sentByMe
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
                          for(String reaction in reactions)
                            Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: GestureDetector(
                              onTap: () {
                                if (message.reactions.keys.contains(reaction)) {
                                  rc.removeReaction(message.id,
                                      message.reactions[reaction]!.id);
                                } else {
                                  rc.sendReaction(reaction, message.id);
                                }
                                entry?.remove();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                  message.reactions.keys.contains(reaction)
                                      ? robinOrange
                                      : null,
                                ),
                                padding: const EdgeInsets.all(9),
                                child: Image.asset(
                                  'assets/images/reactions/$reaction.png',
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
                        message: message,
                        lastInSeries: lastInSeries,
                        firstInSeries: firstInSeries,
                        maxWidth: maxWidth,
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
                              rc.replyMessage = message;
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
                              rc.selectedMessageIds.add(message.id);
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
                              rc.selectedMessageIds.add(message.id);
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
                          GestureDetector(
                            onTap: () {
                              entry?.remove();
                              rc.selectMessageView.value = true;
                              rc.selectedMessageIds.add(message.id);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: loadUrl == null || loadUrl!
          ? () {
              HapticFeedback.selectionClick();
              showOverLay(context);
            }
          : null,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: 55,
        ),
        decoration: BoxDecoration(
          color: message.sentByMe
              ? const Color(0XFFDBE4FF)
              : const Color(0XFFFFFFFF),

          borderRadius: lastInSeries && message.sentByMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(0),
                )
              : lastInSeries && !message.sentByMe
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
            firstInSeries
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 10, top: 7),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 14,
                        color: rc.userColors[message.senderToken] ??
                            const Color(0XFF7A7A7A),
                      ),
                    ),
                  )
                : const SizedBox(),
            message.isAttachment
                ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        fileType(path: message.link) == 'image'
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
                                            //todo: nav to image screen
                                          }
                                        : null,
                                    child: Hero(
                                      tag: message.link,
                                      child: CachedNetworkImage(
                                        imageUrl: message.link,
                                        placeholder: (context, url) =>
                                            const Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 15, 10),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Color(0XFF15AE73),
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  // if (_fileDownloaded) {
                                  //   OpenFile.open(_filePath);
                                  // } else {
                                  //   if (!_fileDownloading) {
                                  //     _downloadFile(widget.messageDetails['content']
                                  //         ['attachment']);
                                  //   }
                                  // }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: const Color(0XFFECEBEB),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/fileTypes/${fileType(path: message.link)}.png',
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
                                                fileName(message.link),
                                                overflow: TextOverflow.ellipsis,
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
                                                    child: fileDownloading.value
                                                        ? const SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2.5,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation(
                                                                green,
                                                              ),
                                                            ),
                                                          )
                                                        : Center(
                                                            child: SvgPicture
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
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dateFormat.format(message.timestamp),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0XFF7A7A7A),
                              ),
                            ),
                            message.sentByMe &&
                                    !rc.currentConversation!.isGroup!
                                ? SizedBox(
                                    height: 10,
                                    child: SvgPicture.asset(
                                      message.isRead
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
                        loadUrl ?? true
                            ? getURLPreview(message.text)
                            : Container(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    (MediaQuery.of(context).size.width * 0.75) -
                                        111,
                              ),
                              child: formatText(message.text),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  dateFormat.format(message.timestamp),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0XFF7A7A7A),
                                  ),
                                ),
                                message.sentByMe &&
                                        !rc.currentConversation!.isGroup!
                                    ? SizedBox(
                                        height: 10,
                                        child: SvgPicture.asset(
                                          message.isRead
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
    );
  }
}
