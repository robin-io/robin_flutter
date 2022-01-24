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

class MessageGroup extends StatelessWidget {
  final RobinMessage message;
  final bool lastInSeries;
  final bool firstInSeries;
  final double maxWidth;
  final bool? loadUrl;

  MessageGroup({
    Key? key,
    required this.message,
    required this.lastInSeries,
    required this.firstInSeries,
    required this.maxWidth,
    this.loadUrl,
  }) : super(key: key);

  final RobinController rc = Get.find();

  Widget renderReply() {
    RobinMessage? reply = rc.conversationMessages[message.replyTo];
    if (reply == null) {
      return Container();
    }
    return Align(
      alignment: reply.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: reply.sentByMe && message.sentByMe
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
                          maxWidth: maxWidth,
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
          : reply.sentByMe && !message.sentByMe
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
                              maxWidth: maxWidth,
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
              : !reply.sentByMe && !message.sentByMe
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
                                  maxWidth: maxWidth,
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
                  : !reply.sentByMe && message.sentByMe
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
                                      maxWidth: maxWidth,
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
        rc.replyMessage = message;
        rc.replyView.value = true;
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: lastInSeries ? 5 : 0,
          left: 10,
          right: 10,
          top: 5,
        ),
        child: Obx(
          () => GestureDetector(
            onTap: rc.selectMessageView.value
                ? () {
                    if (rc.selectedMessageIds.contains(message.id)) {
                      rc.selectedMessageIds.remove(message.id);
                    } else {
                      rc.selectedMessageIds.add(message.id);
                    }
                  }
                : null,
            onLongPress: !rc.selectMessageView.value
                ? () {
                    HapticFeedback.selectionClick();
                    rc.selectMessageView.value = true;
                    rc.selectedMessageIds.add(message.id);
                  }
                : null,
            child: Column(
              children: [
                message.replyTo != null ? renderReply() : Container(),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: message.sentByMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    rc.selectMessageView.value && !message.sentByMe
                        ? Padding(
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            child: rc.selectedMessageIds.contains(message.id)
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
                        TextBubble(
                          message: message,
                          lastInSeries: lastInSeries,
                          firstInSeries: firstInSeries,
                          maxWidth: maxWidth,
                        ),
                        message.sentByMe && message.reactions.isNotEmpty
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color(0XFFEFEFEF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
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
                                    offset: const Offset(-22, -12),
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Color(0XFFEFEFEF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 16,
                                          height: 16,
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
                                    offset: const Offset(-56, -31),
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
                                            for (String reaction in message
                                                .reactions.keys
                                                .toList())
                                              reactions.contains(reaction)
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      child: Image.asset(
                                                        'assets/images/reactions/$reaction.png',
                                                        package:
                                                            'robin_flutter',
                                                        width: 22,
                                                        height: 22,
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
                        !message.sentByMe && message.reactions.isNotEmpty
                            ? Positioned(
                                right: 0,
                                child: Transform.translate(
                                  offset: const Offset(0, -7),
                                  child: Row(
                                    textDirection: ui.TextDirection.rtl,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0XFFFBFBFB),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(20, -7),
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            color: white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: const BoxDecoration(
                                                color: Color(0XFFFBFBFB),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(52, -19),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:  white,
                                            borderRadius: BorderRadius.circular(24),
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
                                                for (String reaction in message
                                                    .reactions.keys
                                                    .toList())
                                                  reactions.contains(reaction)
                                                      ? Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        3),
                                                    child: Image.asset(
                                                      'assets/images/reactions/$reaction.png',
                                                      package:
                                                      'robin_flutter',
                                                      width: 22,
                                                      height: 22,
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
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    rc.selectMessageView.value && message.sentByMe
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5, bottom: 5),
                            child: rc.selectedMessageIds.contains(message.id)
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
