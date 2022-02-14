import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/components/recording_bottom_bar.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

class ChatBottomBar extends StatelessWidget {
  final RobinController rc = Get.find();
  final double bottomPadding;

  ChatBottomBar({Key? key, required this.bottomPadding}) : super(key: key);

  void showOverLay(BuildContext context) {
    var overlay = Overlay.of(context)!;
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  disposeChatOptions();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Material(
                      color: Colors.transparent,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Transform.translate(
                          offset: const Offset(12, -12),
                          child: Container(
                            width: 192,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: white,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    getMedia(source: 'camera');
                                    disposeChatOptions();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Camera',
                                          style: TextStyle(
                                            color: Color(0XFF51545C),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: SvgPicture.asset(
                                            'assets/icons/camera.svg',
                                            package: 'robin_flutter',
                                            width: 22,
                                            height: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const PopupMenuDivider(
                                  height: 2,
                                ),
                                InkWell(
                                  onTap: () {
                                    getMedia(source: 'gallery');
                                    disposeChatOptions();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Photos & Videos',
                                          style: TextStyle(
                                            color: Color(0XFF51545C),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: SvgPicture.asset(
                                            'assets/icons/image.svg',
                                            package: 'robin_flutter',
                                            width: 22,
                                            height: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const PopupMenuDivider(
                                  height: 2,
                                ),
                                InkWell(
                                  onTap: () {
                                    getDocument();
                                    disposeChatOptions();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Document',
                                          style: TextStyle(
                                            color: Color(0XFF51545C),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: SvgPicture.asset(
                                            'assets/icons/document.svg',
                                            package: 'robin_flutter',
                                            width: 22,
                                            height: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: size.height,
            )
          ],
        );
      },
    );
    showChatOptions(entry);
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(
          bottom: bottomPadding + 5,
        ),
        color: white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            rc.replyView.value
                ? Padding(
                    padding: const EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: const Color(0XFFF0F0F0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 49,
                                  color: const Color(0XFF9999BC),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              rc.replyMessage!.sentByMe
                                                  ? 'You'
                                                  : rc.replyMessage!.senderName,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: rc.userColors[rc
                                                        .replyMessage!
                                                        .senderToken] ??
                                                    const Color(0XFF9999BC),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              !rc.replyMessage!.isAttachment
                                                  ? rc.replyMessage!.text
                                                  : fileType(
                                                            path: rc
                                                                .replyMessage!
                                                                .link,
                                                          ) ==
                                                          'image'
                                                      ? "Photo"
                                                      : fileName(rc
                                                          .replyMessage!.link),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          rc.replyMessage!.isAttachment
                              ? fileType(
                                        path: rc.replyMessage!.link,
                                      ) ==
                                      'image'
                                  ? CachedNetworkImage(
                                      imageUrl: rc.replyMessage!.link,
                                      fit: BoxFit.fitHeight,
                                      height: 39,
                                      width: 49,
                                    )
                                  : Image.asset(
                                      'assets/images/fileTypes/${fileType(path: rc.replyMessage!.link)}.png',
                                      package: 'robin_flutter',
                                      fit: BoxFit.fitHeight,
                                      height: 39,
                                      width: 49,
                                    )
                              : Container(),
                          const SizedBox(width: 3),
                          IconButton(
                            onPressed: () {
                              rc.replyView.value = false;
                              rc.replyMessage = null;
                            },
                            icon: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6B7491),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(height: 0),
            rc.file['file'] != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 7,
                        bottom: 7,
                      ),
                      child: Row(
                        children: [
                          fileType() == 'image'
                              ? Image.file(
                                  File(rc.file['file'].path),
                                  fit: BoxFit.fitHeight,
                                  height: 50,
                                  width: 50,
                                )
                              : Image.asset(
                                  'assets/images/fileTypes/${fileType()}.png',
                                  package: 'robin_flutter',
                                  fit: BoxFit.fitHeight,
                                  height: 50,
                                  width: 50,
                                ),
                          const SizedBox(
                            width: 14,
                          ),
                          Expanded(
                            flex: 100,
                            child: Text(
                              fileType() == 'image'
                                  ? 'Photo'
                                  : rc.file['file'].name.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0XFF7A7A7A),
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          rc.isFileSending.value
                              ? Container()
                              : IconButton(
                                  onPressed: () {
                                    rc.file['file'] = null;
                                  },
                                  icon: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6B7491),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  )
                : Container(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: AnimatedSizeAndFade(
                child: rc.isRecording.value
                    ? RecordingBottomBar()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              if (rc.chatOptionsOpened.value) {
                                disposeChatOptions();
                              } else {
                                FocusManager.instance.primaryFocus?.unfocus();
                                showOverLay(context);
                              }
                            },
                            child: Container(
                              width: 52.0,
                              height: 52.0,
                              decoration: const BoxDecoration(
                                color: Color(0XFFF5F7FC),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 250),
                                  firstChild: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 250),
                                    opacity:
                                        !rc.chatOptionsOpened.value ? 0 : 1,
                                    child: const Icon(
                                      Icons.close,
                                      color: Color(0XFF51545C),
                                    ),
                                  ),
                                  secondChild: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: rc.chatOptionsOpened.value ? 0 : 1,
                                    child: const Icon(
                                      Icons.add,
                                      color: green,
                                    ),
                                  ),
                                  crossFadeState: rc.chatOptionsOpened.value
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(
                                color: Color(0XFF535F89),
                                fontSize: 14,
                              ),
                              controller: rc.messageController,
                              focusNode: rc.messageFocus,
                              textInputAction: TextInputAction.send,
                              onFieldSubmitted: (text) {
                                if (!rc.isFileSending.value) {
                                  if (rc.file['file'] != null) {
                                    if (rc.replyView.value) {
                                      rc.sendReplyAsAttachment();
                                    } else {
                                      rc.sendAttachment();
                                    }
                                  } else if (rc
                                      .messageController.text.isNotEmpty) {
                                    if (rc.replyView.value) {
                                      rc.sendReplyAsTextMessage();
                                    } else {
                                      rc.sendTextMessage();
                                    }
                                  }
                                }
                              },
                              decoration:
                                  textFieldDecoration(radius: 24, style: 2)
                                      .copyWith(
                                hintText: 'Type a message...',
                                fillColor: const Color(0XFFFBFBFB),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          AnimatedCrossFade(
                            firstChild: GestureDetector(
                              onTap: () {
                                if (!rc.isFileSending.value) {
                                  if (rc.file['file'] != null) {
                                    if (rc.replyView.value) {
                                      rc.sendReplyAsAttachment();
                                    } else {
                                      rc.sendAttachment();
                                    }
                                  } else if (rc
                                      .messageController.text.isNotEmpty) {
                                    if (rc.replyView.value) {
                                      rc.sendReplyAsTextMessage();
                                    } else {
                                      rc.sendTextMessage();
                                    }
                                  }
                                }
                              },
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: const BoxDecoration(
                                  color: Color(0XFF15AE73),
                                  shape: BoxShape.circle,
                                ),
                                child: rc.isFileSending.value
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0XFFFFFFFF),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/send.svg',
                                          package: 'robin_flutter',
                                          semanticsLabel: 'edit',
                                          width: 22,
                                          height: 22,
                                        ),
                                      ),
                              ),
                            ),
                            secondChild: InkWell(
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                rc.isRecording.value = true;
                              },
                              child: SvgPicture.asset(
                                'assets/icons/microphone.svg',
                                package: 'robin_flutter',
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // secondChild: const SizedBox(
                            //   height: 24,
                            //   width: 1,
                            // ),
                            crossFadeState: rc.showSendButton.value ||
                                    rc.file['file'] != null
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 200),
                          )
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
