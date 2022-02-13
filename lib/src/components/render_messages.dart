import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/components/message-group/message_group.dart';

class RenderMessages extends StatelessWidget {
  RenderMessages({
    Key? key,
  }) : super(key: key) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!rc.finishedInitialScroll.value) {
        Future.delayed(const Duration(milliseconds: 5), () {
          rc.messagesScrollController.jumpTo(
            rc.messagesScrollController.position.maxScrollExtent - 10,
          );
          rc.messagesScrollController.addListener(() {
            if (rc.messagesScrollController.position.pixels <
                rc.messagesScrollController.position.maxScrollExtent - 120) {
              rc.atMaxScroll.value = false;
            } else if (!rc.atMaxScroll.value) {
              rc.atMaxScroll.value = true;
            }
          });
          rc.finishedInitialScroll.value = true;
        });
      }
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
            itemBuilder: (context, index) {
              RobinMessage message =
                  rc.conversationMessages.values.toList()[index];
              return MessageGroup(
                message: message,
                lastInSeries: (index < rc.conversationMessages.length - 1 &&
                        rc.conversationMessages.values
                                .toList()[index + 1]
                                .senderToken !=
                            message.senderToken) ||
                    index == rc.conversationMessages.length - 1,
                firstInSeries: !rc.currentConversation.value.isGroup!
                    ? false
                    : message.sentByMe
                        ? false
                        : (index > 0 &&
                                rc.conversationMessages.values
                                        .toList()[index - 1]
                                        .senderToken !=
                                    message.senderToken) ||
                            index == 0,
                maxWidth: maxWidth,
              );
            },
            controller: rc.messagesScrollController,
          ),
          !rc.finishedInitialScroll.value
              ? Container(
                  color: white,
                )
              : Container(),
        ],
      ),
    );
  }
}
