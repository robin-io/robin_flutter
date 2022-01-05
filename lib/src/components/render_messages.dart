import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/components/text_bubble.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_message.dart';

class RenderMessages extends StatelessWidget {
  RenderMessages({
    Key? key,
  }) : super(key: key) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      rc.messagesScrollController.jumpTo(
        rc.messagesScrollController.position.maxScrollExtent,
      );
    });
  }

  final RobinController rc = Get.find();

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width * 0.7;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
      child: Obx(
        () => ListView.builder(
          itemCount: rc.conversationMessages.length,
          itemBuilder: (context, index) {
            RobinMessage message =
                rc.conversationMessages.values.toList()[index];
            return TextBubble(
              message: message,
              lastInSeries: (index < rc.conversationMessages.length - 1 &&
                      rc.conversationMessages.values
                              .toList()[index + 1]
                              .senderToken !=
                          message.senderToken) ||
                  index == rc.conversationMessages.length - 1,
              firstInSeries: !rc.currentConversation!.isGroup!
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
      ),
    );
  }
}
