import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:get/get.dart';

class ChatBottomSheet extends StatelessWidget {
  final RobinController rc = Get.find();
  final double bottomPadding;

  ChatBottomSheet({Key? key, required this.bottomPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(
          bottom: bottomPadding,
        ),
        decoration: const BoxDecoration(
          color: white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 104, 255, 0.065),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, -2), // changes position of shadow
            ),
          ],
        ),
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
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 49,
                                color: const Color(0XFF8393C0),
                              ),
                              const SizedBox(
                                width: 14,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    rc.replyMessage!.senderName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: rc.userColors[
                                              rc.replyMessage!.senderToken] ??
                                          green,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 72,
                                    child: Text(
                                      true
                                          ? rc.replyMessage!.text
                                          : false
                                              ? ""
                                              : "${rc.currentConversation!.name}",
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
                          true ? const SizedBox(width: 3) : Container(),
                          false
                              ? Container(
                                  width: 49,
                                  height: 49,
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: true
                                      ? CachedNetworkImage(
                                          imageUrl: '',
                                          fit: BoxFit.fitHeight,
                                          height: 39,
                                          width: 49,
                                        )
                                      : Image.asset(
                                          'assets/images/fileTypes/.png',
                                          package: 'robin_flutter',
                                          fit: BoxFit.fitHeight,
                                          height: 39,
                                          width: 49,
                                        ),
                                )
                              : Container(),
                          const SizedBox(width: 3),
                          IconButton(
                            onPressed: () {
                              rc.replyView.value = false;
                              rc.replyMessage = RobinMessage.empty();
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      style: const TextStyle(
                        color: Color(0XFF535F89),
                        fontSize: 14,
                      ),
                      controller: rc.messageController,
                      decoration: textFieldDecoration(radius: 24).copyWith(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  rc.showSendButton.value || rc.file['file'] != null
                      ? GestureDetector(
                          onTap: () {
                            if (!rc.isFileSending.value) {
                              if (rc.file['file'] != null) {
                                rc.sendAttachment();
                                //todo: send file reply
                              } else if (rc.messageController.text.isNotEmpty) {
                                rc.sendTextMessage();
                                //todo: send reply
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
                        )
                      : SizedBox(
                          width: 45,
                          child: PopupMenuButton(
                            padding: const EdgeInsets.all(0),
                            icon: SizedBox(
                              width: 27,
                              height: 27,
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/attach.svg',
                                  package: 'robin_flutter',
                                  width: 27,
                                  height: 27,
                                ),
                              ),
                            ),
                            enableFeedback: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(24.0),
                              ),
                            ),
                            onSelected: (value) async {
                              if (value == 1) {
                                getMedia(source: 'camera');
                              } else if (value == 2) {
                                getMedia(source: 'gallery');
                              } else if (value == 3) {
                                getDocument();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/camera.svg',
                                          package: 'robin_flutter',
                                          width: 22,
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Camera",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0XFF101010),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/image.svg',
                                          package: 'robin_flutter',
                                          width: 22,
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Photos & Videos",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0XFF101010),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Center(
                                        child: SvgPicture.asset(
                                          'assets/icons/document.svg',
                                          package: 'robin_flutter',
                                          width: 22,
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Document",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0XFF101010),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
