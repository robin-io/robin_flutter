import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/widgets/conversations_loading.dart';
import 'package:robin_flutter/src/widgets/empty_conversation.dart';
import 'package:robin_flutter/src/widgets/conversation.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:get/get.dart';

class RobinChat extends StatelessWidget {
  final RobinConversation conversation;
  final RobinController rc = Get.find();

  RobinChat({Key? key, required this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        leading: goBack(context),
        title: const Text(
          'Archived Chats',
          style: TextStyle(
            color: black,
            fontSize: 15,
          ),
        ),
        shadowColor: const Color.fromRGBO(0, 104, 255, 0.075),
        centerTitle: true,
      ),
      body: Text(conversation.name!),
    );
  }
}
