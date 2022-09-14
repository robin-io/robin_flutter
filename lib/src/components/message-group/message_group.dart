import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/components/swipe.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/components/message-group/reply_arc.dart';
import 'package:robin_flutter/src/components/message-group/text_bubble.dart';

import '../measure_size.dart';

class MessageGroup extends StatefulWidget {
  final RobinMessage message;
  final bool lastInSeries;
  final bool firstInSeries;
  final double maxWidth;
  final bool? loadUrl;

  const MessageGroup({
    Key? key,
    required this.message,
    required this.lastInSeries,
    required this.firstInSeries,
    required this.maxWidth,
    this.loadUrl,
  }) : super(key: key);

  @override
  State<MessageGroup> createState() => _MessageGroupState();
}

class _MessageGroupState extends State<MessageGroup> {
  final RobinController rc = Get.find();

  double textBubbleSize = 60;

  Widget renderReply() {
    RobinMessage? reply = rc.conversationMessages[widget.message.replyTo];
    if (reply == null) {
      return Container();
    }
    return Align(
      alignment: reply.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: reply.sentByMe && widget.message.sentByMe
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                reply.isAttachment && fileType(path: reply.link) == 'image'
                    ? CachedNetworkImage(
                        imageUrl: reply.link,
                        fit: BoxFit.fitHeight,
                        height: 49,
                        width: 49,
                      )
                    : Container(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        constraints: BoxConstraints(
                          maxWidth: widget.maxWidth,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0XFFE8EDF8),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(0),
                          ),
                        ),
                        child: reply.isAttachment
                            ? RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Image.asset(
                                          'assets/images/fileTypes/${fileType(
                                            path: reply.link,
                                          )}.png',
                                          package: 'robin_flutter',
                                          fit: BoxFit.fitHeight,
                                          height: 16,
                                          width: 16,
                                        ),
                                      ),
                                    ),
                                    const WidgetSpan(
                                      child: Text(
                                        'File',
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1,
                                          color: Color(0XFF9CABC8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                reply.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0XFF9CABC8),
                                ),
                              ),
                      ),
                const SizedBox(height: 6),
                Container(
                  width: 2,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0XFF6B7491),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
              ],
            )
          : reply.sentByMe && !widget.message.sentByMe
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    reply.isAttachment && fileType(path: reply.link) == 'image'
                        ? CachedNetworkImage(
                            imageUrl: reply.link,
                            fit: BoxFit.fitHeight,
                            height: 49,
                            width: 49,
                          )
                        : Container(
                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            constraints: BoxConstraints(
                              maxWidth: widget.maxWidth,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0XFFDBF3EA),
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(0),
                              ),
                            ),
                            child: reply.isAttachment
                                ? RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Image.asset(
                                              'assets/images/fileTypes/${fileType(
                                                path: reply.link,
                                              )}.png',
                                              package: 'robin_flutter',
                                              fit: BoxFit.fitHeight,
                                              height: 16,
                                              width: 16,
                                            ),
                                          ),
                                        ),
                                        const WidgetSpan(
                                          child: Text(
                                            'File',
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1,
                                              color: Color(0XFF8FBFAD),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(
                                    reply.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFF8FBFAD),
                                    ),
                                  ),
                          ),
                    const SizedBox(height: 6),
                    Transform.translate(
                      offset: const Offset(2, -5),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: CustomPaint(
                          size: const Size(24, 24),
                          painter: ReplyArc(),
                        ),
                      ),
                    ), //
                    const SizedBox(height: 3),
                  ],
                )
              : !reply.sentByMe && !widget.message.sentByMe
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        reply.isAttachment &&
                                fileType(path: reply.link) == 'image'
                            ? CachedNetworkImage(
                                imageUrl: reply.link,
                                fit: BoxFit.fitHeight,
                                height: 49,
                                width: 49,
                              )
                            : Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                constraints: BoxConstraints(
                                  maxWidth: widget.maxWidth,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0XFFE8EDF8),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: reply.isAttachment
                                    ? RichText(
                                        text: TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Image.asset(
                                                  'assets/images/fileTypes/${fileType(
                                                    path: reply.link,
                                                  )}.png',
                                                  package: 'robin_flutter',
                                                  fit: BoxFit.fitHeight,
                                                  height: 16,
                                                  width: 16,
                                                ),
                                              ),
                                            ),
                                            const WidgetSpan(
                                              child: Text(
                                                'File',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  height: 1,
                                                  color: Color(0XFF9CABC8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(
                                        reply.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0XFF9CABC8),
                                        ),
                                      ),
                              ),
                        const SizedBox(height: 6),
                        Container(
                          width: 2,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0XFF6B7491),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                    )
                  : !reply.sentByMe && widget.message.sentByMe
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            reply.isAttachment &&
                                    fileType(path: reply.link) == 'image'
                                ? CachedNetworkImage(
                                    imageUrl: reply.link,
                                    fit: BoxFit.fitHeight,
                                    height: 49,
                                    width: 49,
                                  )
                                : Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 10, 15, 10),
                                    constraints: BoxConstraints(
                                      maxWidth: widget.maxWidth,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0XFFDBF3EA),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: reply.isAttachment
                                        ? RichText(
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Image.asset(
                                                      'assets/images/fileTypes/${fileType(
                                                        path: reply.link,
                                                      )}.png',
                                                      package: 'robin_flutter',
                                                      fit: BoxFit.fitHeight,
                                                      height: 16,
                                                      width: 16,
                                                    ),
                                                  ),
                                                ),
                                                const WidgetSpan(
                                                  child: Text(
                                                    'File',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      height: 1,
                                                      color: Color(0XFF8FBFAD),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Text(
                                            reply.text,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0XFF8FBFAD),
                                            ),
                                          ),
                                  ),
                            const SizedBox(height: 6),
                            Transform.translate(
                              offset: const Offset(2, -5),
                              child: CustomPaint(
                                size: const Size(24, 24),
                                painter: ReplyArc(),
                              ),
                            ), //
                            const SizedBox(height: 3),
                          ],
                        )
                      : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Swipe(
      onSwipeRight: () {
        HapticFeedback.selectionClick();
        rc.replyView.value = false;
        rc.replyMessage = widget.message;
        rc.replyView.value = true;
        rc.messageFocus.requestFocus();
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: widget.lastInSeries ? 5 : 0,
          left: 10,
          right: 10,
          top: widget.message.allReactions.isNotEmpty ? 28 : 5,
        ),
        child: Obx(
          () => GestureDetector(
            onTap: rc.selectMessageView.value
                ? () {
                    if (rc.selectedMessageIds.contains(widget.message.id)) {
                      if (widget.message.isGroupOfAttachments) {
                        for (String messageId in widget.message.groupIds) {
                          rc.selectedMessageIds.remove(messageId);
                        }
                      } else {
                        rc.selectedMessageIds.remove(widget.message.id);
                      }
                      if (rc.selectedMessageIds.isEmpty) {
                        rc.selectMessageView.value = false;
                      }
                    } else {
                      if (widget.message.isGroupOfAttachments) {
                        rc.selectedMessageIds.value += widget.message.groupIds;
                      } else {
                        rc.selectedMessageIds.add(widget.message.id);
                      }
                    }
                  }
                : null,
            // onLongPress: !rc.selectMessageView.value
            //     ? () {
            //         HapticFeedback.selectionClick();
            //         rc.selectMessageView.value = true;
            //         if (widget.message.isGroupOfAttachments) {
            //           rc.selectedMessageIds.value = widget.message.groupIds;
            //         } else {
            //           rc.selectedMessageIds.value = [widget.message.id];
            //         }
            //       }
            //     : null,
            child: Column(
              children: [
                // message.replyTo != null ? renderReply() : Container(),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: widget.message.sentByMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    rc.selectMessageView.value && !widget.message.sentByMe
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            child: rc.selectedMessageIds
                                    .contains(widget.message.id)
                                ? Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: green,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: white,
                                        size: 14,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 2,
                                        color: const Color(0XFFBBC1D6),
                                      ),
                                    ),
                                  ),
                          )
                        : Container(),
                    Stack(
                      children: [
                        MeasureSize(
                          onChange: (size) {
                            if (mounted) {
                              setState(() {
                                textBubbleSize = size.width;
                              });
                            }
                          },
                          child: TextBubble(
                            key: Key(widget.message.id),
                            message: widget.message,
                            lastInSeries: widget.lastInSeries,
                            firstInSeries: widget.firstInSeries,
                            maxWidth: widget.maxWidth,
                          ),
                        ),
                        widget.message.sentByMe &&
                                widget.message.allReactions.isNotEmpty
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8.7,
                                    height: 8.7,
                                    decoration: const BoxDecoration(
                                      color: Color(0XFFEFEFEF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 5.8,
                                        height: 5.8,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0XFFECEBEB),
                                            width: 2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(-16, -7),
                                    child: Container(
                                      width: 13,
                                      height: 13,
                                      decoration: const BoxDecoration(
                                        color: Color(0XFFEFEFEF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 11.6,
                                          height: 11.6,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0XFFECEBEB),
                                              width: 2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(-45, -25),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0XFFEFEFEF),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0XFFECEBEB),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Row(
                                          children: [
                                            for (String reaction in widget
                                                .message.allReactions.keys
                                                .toList())
                                              reactions.contains(reaction)
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/reactions/${reactionToText(reaction)}.png',
                                                            package:
                                                                'robin_flutter',
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                          widget
                                                                      .message
                                                                      .allReactions[
                                                                          reaction]!
                                                                      .number >
                                                                  1
                                                              ? Text(
                                                                  widget
                                                                      .message
                                                                      .allReactions[
                                                                          reaction]!
                                                                      .number
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0XFF51545C),
                                                                  ),
                                                                )
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        !widget.message.sentByMe &&
                                widget.message.allReactions.isNotEmpty
                            ? Transform.translate(
                                offset: Offset(
                                    (textBubbleSize - 36) -
                                        (widget.message.allReactions.length *
                                            24),
                                    -7),
                                child: Row(
                                  textDirection: ui.TextDirection.rtl,
                                  children: [
                                    Container(
                                      width: 8.7,
                                      height: 8.7,
                                      decoration: const BoxDecoration(
                                        color: white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 5.6,
                                          height: 5.6,
                                          decoration: const BoxDecoration(
                                            color: Color(0XFFFBFBFB),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(15, -5),
                                      child: Container(
                                        width: 13,
                                        height: 13,
                                        decoration: const BoxDecoration(
                                          color: white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 11.6,
                                            height: 11.6,
                                            decoration: const BoxDecoration(
                                              color: Color(0XFFFBFBFB),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(40, -15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: white,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0XFFFBFBFB),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                          child: Row(
                                            children: [
                                              for (String reaction in widget
                                                  .message.allReactions.keys
                                                  .toList())
                                                reactions.contains(reaction)
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              'assets/images/reactions/${reactionToText(reaction)}.png',
                                                              package:
                                                                  'robin_flutter',
                                                              width: 15,
                                                              height: 15,
                                                            ),
                                                            widget
                                                                        .message
                                                                        .allReactions[
                                                                            reaction]!
                                                                        .number >
                                                                    1
                                                                ? Text(
                                                                    widget
                                                                        .message
                                                                        .allReactions[
                                                                            reaction]!
                                                                        .number
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          14,
                                                                      color: Color(
                                                                          0XFF51545C),
                                                                    ),
                                                                  )
                                                                : const SizedBox(),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    rc.selectMessageView.value && widget.message.sentByMe
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5, bottom: 5),
                            child: rc.selectedMessageIds
                                    .contains(widget.message.id)
                                ? Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: green,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: white,
                                        size: 14,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 2,
                                        color: const Color(0XFFBBC1D6),
                                      ),
                                    ),
                                  ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
