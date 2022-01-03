import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/views/robin_archived.dart';
import 'package:robin_flutter/src/widgets/conversations_loading.dart';
import 'package:robin_flutter/src/widgets/empty_conversation.dart';
import 'package:robin_flutter/src/widgets/conversation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robin_flutter/src/models/robin_current_user.dart';
import 'package:robin_flutter/src/models/robin_keys.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';

class Robin extends StatelessWidget {
  final String apiKey;
  final RobinCurrentUser currentUser;
  final Function getUsers;
  final RobinKeys keys;

  Robin({
    Key? key,
    required this.apiKey,
    required this.currentUser,
    required this.getUsers,
    required this.keys,
  }) : super(key: key) {
    rc.initializeController(apiKey, currentUser, getUsers, keys);
  }

  final RobinController rc = Get.put(RobinController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFAFAFA),
      appBar: AppBar(
        backgroundColor: white,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: blueGrey,
            fontSize: 16,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/edit.svg',
              semanticsLabel: 'edit',
              package: 'robin_flutter',
              width: 20,
              height: 20,
            ),
            onPressed: () {
              showCreateConversation(context);
            },
          )
        ],
        shadowColor: const Color.fromRGBO(0, 104, 255, 0.2),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                child: TextFormField(
                  style: const TextStyle(
                    color: Color(0XFF535F89),
                    fontSize: 14,
                  ),
                  controller: rc.homeSearchController,
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
                    hintText: 'Search Messages...',
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RobinArchived(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(
                    'Archived',
                    style: TextStyle(
                      color: green,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(
        () {
          if (rc.isConversationsLoading.value) {
            return const ConversationsLoading();
          } else if (rc.homeConversations.isEmpty) {
            return const EmptyConversation();
          } else {
            return ListView(
              children: [
                for (RobinConversation conversation in rc.homeConversations)
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
