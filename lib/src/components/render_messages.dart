import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/components/message-group/message_group.dart';

class RenderMessages extends StatelessWidget {
  RenderMessages({
    Key? key,
  }) : super(key: key) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      rc.messagesScrollController.addListener(() {
        if (rc.messagesScrollController.position.pixels > 250) {
          rc.atMaxScroll.value = false;
        } else if (!rc.atMaxScroll.value) {
          rc.atMaxScroll.value = true;
        }
      });
    });
  }

  final RobinController rc = Get.find();

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.7;
    return Obx(
      () => Stack(
        children: [
          ListView.builder(
            itemCount: rc.conversationMessages.length,
            reverse: true,
            shrinkWrap: rc.conversationMessages.length < 25,
            itemBuilder: (context, index) {
              RobinMessage message =
                  rc.conversationMessages.values.toList()[index];
              if (index < rc.conversationMessages.length - 1) {
                RobinMessage nextMessage =
                    rc.conversationMessages.values.toList()[index + 1];
                if (message.timestamp.day != nextMessage.timestamp.day) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7, 12, 7, 7),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 3, 20, 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0XFFBBC4DF),
                          ),
                          child: Text(
                            formatTimestamp(message.timestamp),
                            style: const TextStyle(
                              color: black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      MessageGroup(
                        message: message,
                        lastInSeries: (index > 0 &&
                                rc.conversationMessages.values
                                        .toList()[index - 1]
                                        .senderToken !=
                                    message.senderToken) ||
                            index == 0,
                        firstInSeries: !rc.currentConversation.value.isGroup!
                            ? false
                            : message.sentByMe
                                ? false
                                : (index < rc.conversationMessages.length - 1 &&
                                        rc.conversationMessages.values
                                                .toList()[index + 1]
                                                .senderToken !=
                                            message.senderToken) ||
                                    index == rc.conversationMessages.length - 1,
                        maxWidth: maxWidth,
                      ),
                    ],
                  );
                }
              }
              if (index == rc.conversationMessages.length - 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(7, 12, 7, 7),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 3, 20, 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0XFFBBC4DF),
                        ),
                        child: Text(
                          formatTimestamp(message.timestamp),
                          style: const TextStyle(
                            color: black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    MessageGroup(
                      message: message,
                      lastInSeries: (index > 0 &&
                              rc.conversationMessages.values
                                      .toList()[index - 1]
                                      .senderToken !=
                                  message.senderToken) ||
                          index == 0,
                      firstInSeries: !rc.currentConversation.value.isGroup!
                          ? false
                          : message.sentByMe
                              ? false
                              : (index < rc.conversationMessages.length - 1 &&
                                      rc.conversationMessages.values
                                              .toList()[index + 1]
                                              .senderToken !=
                                          message.senderToken) ||
                                  index == rc.conversationMessages.length - 1,
                      maxWidth: maxWidth,
                    ),
                  ],
                );
              }
              return MessageGroup(
                message: message,
                lastInSeries: (index > 0 &&
                        rc.conversationMessages.values
                                .toList()[index - 1]
                                .senderToken !=
                            message.senderToken) ||
                    index == 0,
                firstInSeries: !rc.currentConversation.value.isGroup!
                    ? false
                    : message.sentByMe
                        ? false
                        : (index < rc.conversationMessages.length - 1 &&
                                rc.conversationMessages.values
                                        .toList()[index + 1]
                                        .senderToken !=
                                    message.senderToken) ||
                            index == rc.conversationMessages.length - 1,
                maxWidth: maxWidth,
              );
            },
            controller: rc.messagesScrollController,
          ),
        ],
      ),
    );
  }
}
