import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

import '../../utils/functions.dart';
import 'package:http/http.dart' as http;

class MessageOptions extends StatefulWidget {
  final RobinMessage message;
  final OverlayEntry? entry;

  const MessageOptions({
    Key? key,
    required this.message,
    required this.entry,
  }) : super(key: key);

  @override
  State<MessageOptions> createState() => _MessageOptionsState();
}

class _MessageOptionsState extends State<MessageOptions> {
  final RobinController rc = Get.find();

  bool _expand = false;

  _startAnimation() {
    Future.delayed(const Duration(milliseconds: 20), () {
      setState(() {
        _expand = true;
      });
    });
  }

  double _fullHeight() {
    double items = 2;
    if (rc.canForwardMessages) items += 1;
    if (!widget.message.isAttachment) items += 1;
    if (!widget.message.delivered) items += 1;
    if (rc.canDeleteMessages && checkDeleteDuration(widget.message.timestamp)) {
      items += 1;
    }
    return items * 46.5;
  }

  @override
  void initState() {
    _startAnimation();
    super.initState();
  }

  void retryMessage() async{
    rc.appResume();
    Map message = widget.message.toJson();

    if (widget.message.isAttachment) {
      rc.isFileSending.value = true;
      if (widget.message.replyTo != null) {
        Map<String, String> body = {
          'conversation_id': message['conversation_id'],
          'message_id': message['reply_to'],
          'sender_token': message['sender_token'],
          'sender_name': message['sender_token'],
          'msg': message['content']['msg'],
          'timestamp': DateTime.now().toString(),
          'file_path': message['content']['attachment'],
          'local_id': message['_id'],
        };
        List<http.MultipartFile> files = [
          await http.MultipartFile.fromPath(
            'file',
            message['content']['attachment'],
          ),
        ];
        rc.robinCore!.replyWithAttachment(body, files);
        rc.isFileSending.value = false;
      } else {
        Map<String, String> body = {
          'conversation_id': message['conversation_id'],
          'sender_token': message['sender_token'],
          'sender_name': message['sender_token'],
          'msg': message['content']['msg'],
          'timestamp': DateTime.now().toString(),
          'file_path': message['content']['attachment'],
          'local_id': message['_id'],
        };
        List<http.MultipartFile> files = [
          await http.MultipartFile.fromPath(
            'file',
            message['content']['attachment'],
          ),
        ];
        rc.robinCore!.sendAttachment(body, files);
        rc.isFileSending.value = false;
      }
    } else {
      Map<String, String> msg = {
        'msg': message['content']['msg'],
        'timestamp': DateTime.now().toString(),
        'sender_token': message['sender_token'],
        'sender_name': message['sender_token'],
        'local_id': message['_id']
      };
      if (widget.message.replyTo != null) {
        rc.robinCore!.replyToMessage(
            msg,
            message['conversation_id'],
            rc.currentUser!.robinToken,
            rc.currentUser!.fullName,
            message['reply_to']);
      } else {
        rc.robinCore!.sendTextMessage(
          msg,
          message['conversation_id'],
          rc.currentUser!.robinToken,
          rc.currentUser!.fullName,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 195),
      width: 195,
      height: _expand ? _fullHeight() : 5,
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                widget.entry?.remove();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            rc.canForwardMessages
                ? GestureDetector(
                    onTap: () {
                      widget.entry?.remove();
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  )
                : Container(),
            !widget.message.isAttachment
                ? GestureDetector(
                    onTap: () {
                      widget.entry?.remove();
                      Clipboard.setData(
                        ClipboardData(
                          text: widget.message.text,
                        ),
                      );
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Copy",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0XFF101010),
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.content_copy,
                            size: 22,
                            color: Color(0XFF51545C),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            GestureDetector(
              onTap: () {
                widget.entry?.remove();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            !widget.message.delivered
                ? GestureDetector(
                    onTap: () {
                      widget.entry?.remove();
                      retryMessage();
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Retry",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0XFF101010),
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.refresh,
                            size: 22,
                            color: Color(0XFF51545C),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            rc.canDeleteMessages &&
                    checkDeleteDuration(widget.message.timestamp)
                ? GestureDetector(
                    onTap: () {
                      widget.entry?.remove();
                      rc.selectMessageView.value = true;
                      rc.selectedMessageIds.add(widget.message.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
