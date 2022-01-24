import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/components/conversations_loading.dart';
import 'package:robin_flutter/src/components/empty_conversation.dart';
import 'package:robin_flutter/src/components/conversation.dart';
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
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              child: IconButton(
                icon:  const Icon(
                  Icons.close,
                  size: 24,
                  color:  Color(0XFF51545C),
                ),
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
             const SizedBox(width: 5),
             const Text(
              'Archived Messages',
              style: TextStyle(
                color: black,
                fontSize: 15,
              ),
            ),
          ],
        ),
        shadowColor: const Color.fromRGBO(0, 50, 201, 0.2),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 18, 15, 18),
            child: TextFormField(
              style: const TextStyle(
                color: Color(0XFF535F89),
                fontSize: 14,
              ),
              cursorColor: const Color(0XFF535F89),
              controller: rc.archiveSearchController,
              decoration: textFieldDecoration().copyWith(
                prefixIcon: SizedBox(
                  width: 22,
                  height: 22,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/search.svg',
                      semanticsLabel: 'search',
                      package: 'robin_flutter',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
                hintText: 'Search People...',
              ),
            ),
          ),
          Obx(
            () {
              if (rc.isConversationsLoading.value) {
                return const ConversationsLoading();
              } else if (rc.archivedConversations.isEmpty) {
                return const EmptyConversation();
              } else {
                return Expanded(
                  child: ListView(
                    children: [
                      for (RobinConversation conversation in rc.archivedConversations)
                        Conversation(
                          conversation: conversation,
                        )
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
