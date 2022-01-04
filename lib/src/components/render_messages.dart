import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
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
    return Obx(
      () => ListView.builder(
        itemCount: rc.conversationMessages.length,
        itemBuilder: (context, index) => Text(
          '$index...',
          style: const TextStyle(
            fontSize: 17,
          ),
        ),
        controller: rc.messagesScrollController,
      ),
    );
  }
}
