import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/widgets/conversations_loading.dart';
import 'package:robin_flutter/src/widgets/empty_conversation.dart';
import 'package:robin_flutter/src/widgets/conversation.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:get/get.dart';

class RobinArchived extends StatelessWidget {

  final RobinController rc = Get.find();

  RobinArchived({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        leading: backButton(context),
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
      body: Obx(
        () {
          if (rc.isConversationsLoading.value) {
            return const ConversationsLoading();
          } else if (rc.archivedConversations.isEmpty) {
            return const EmptyConversation();
          } else {
            return ListView(
              children: [
                for (RobinConversation conversation in rc.archivedConversations)
                  Conversation(
                    conversation: conversation,
                  )
              ],
            );
          }
        },
      ),
    );
  }
}
