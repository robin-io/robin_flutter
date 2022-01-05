import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/components/text_bubble.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

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
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Obx(
        () => ListView.builder(
          itemCount: rc.conversationMessages.length,
          itemBuilder: (context, index) => TextBubble(
            message: rc.conversationMessages.values.toList()[index],
            lastInSeries: false,
            maxWidth: maxWidth,
          ),
          controller: rc.messagesScrollController,
        ),
      ),
    );
  }
}
