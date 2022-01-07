import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robin_flutter/src/components/message-group/text_bubble.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/components/swipe.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

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
            onTap: rc.forwardView.value
                ? () {
                    if (rc.forwardMessageIds.contains(message.id)) {
                      rc.forwardMessageIds.remove(message.id);
                    } else {
                      rc.forwardMessageIds.add(message.id);
                    }
                  }
                : null,
            onLongPress: !rc.forwardView.value
                ? () {
                    HapticFeedback.selectionClick();
                    rc.forwardView.value = true;
                    rc.forwardMessageIds.add(message.id);
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: message.sentByMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                rc.forwardView.value && !message.sentByMe
                    ? Padding(
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        child: rc.forwardMessageIds.contains(message.id)
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
                TextBubble(
                  message: message,
                  lastInSeries: lastInSeries,
                  firstInSeries: firstInSeries,
                  maxWidth: maxWidth,
                ),
                rc.forwardView.value && message.sentByMe
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        child: rc.forwardMessageIds.contains(message.id)
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
          ),
        ),
      ),
    );
  }
}
