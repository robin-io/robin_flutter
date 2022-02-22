import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robin_flutter/src/models/robin_user.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/views/robin_chat.dart';
import 'package:robin_flutter/src/components/robin_create_group.dart';
import 'package:robin_flutter/src/components/user_avatar.dart';
import 'package:robin_flutter/src/components/users_loading.dart';

class RobinCreateConversation extends StatelessWidget {
  final RobinController rc = Get.find();

  RobinCreateConversation({Key? key}) : super(key: key) {
    rc.getAllUsers();
  }

  List<Widget> renderUsers(BuildContext context) {
    List<Widget> users = [];
    String currentLetter = '';
    for (RobinUser user in rc.allUsers) {
      if (user.displayName[0].toLowerCase() != currentLetter.toLowerCase()) {
        currentLetter = user.displayName[0].toLowerCase();
        users.add(
          Container(
            padding: const EdgeInsets.fromLTRB(15, 7, 0, 7),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0XFFF5F7FC),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              currentLetter.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                color: black,
              ),
            ),
          ),
        );
      }
      users.add(
        InkWell(
          onTap: () async {
            if (rc.allConversations.isEmpty) {
              Map<String, String> body = {
                'receiver_name': user.displayName,
                'receiver_token': user.robinToken,
              };
              RobinConversation conversation =
                  await rc.createConversation(body);
              try {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RobinChat(
                      conversation: conversation,
                    ),
                  ),
                ).then((value) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    rc.currentConversation.value = RobinConversation.empty();
                  });
                });
              } finally {
                // widget was disposed before conversation was created
              }
            } else {
              for (RobinConversation conversation
                  in rc.allConversations.values.toList()) {
                if (user.robinToken == conversation.token) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RobinChat(
                        conversation: conversation,
                      ),
                    ),
                  ).then((value) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      rc.currentConversation.value = RobinConversation.empty();
                    });
                  });
                } else {
                  Map<String, String> body = {
                    'receiver_name': user.displayName,
                    'receiver_token': user.robinToken,
                  };
                  RobinConversation conversation =
                      await rc.createConversation(body);
                  try {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RobinChat(
                          conversation: conversation,
                        ),
                      ),
                    ).then((value) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        rc.currentConversation.value =
                            RobinConversation.empty();
                      });
                    });
                  } finally {
                    // widget was disposed before conversation was created
                  }
                }
              }
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 3,
                  style: BorderStyle.solid,
                  color: Color(0XFFF6F8FD),
                ),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 12, bottom: 12, left: 15, right: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatar(
                  name: user.displayName,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.displayName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      color: black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: MediaQuery.of(context).size.height - 70,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 24,
                        color: Color(0XFF51545C),
                      ),
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'New Chat',
                    style: TextStyle(
                      color: black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextFormField(
                style: const TextStyle(
                  color: Color(0XFF8D9091),
                  fontSize: 14,
                ),
                cursorColor: const Color(0XFF8D9091),
                controller: rc.allUsersSearchController,
                decoration: textFieldDecoration().copyWith(
                  prefixIcon: SizedBox(
                    width: 22,
                    height: 22,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/search_grey.svg',
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
            InkWell(
              onTap: () {
                rc.allUsersSearchController.clear();
                rc.createGroupParticipants.value = {};
                showCreateGroupChat(context);
              },
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: Color(0XFFEFEFEF),
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 12, bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/users.svg',
                        package: 'robin_flutter',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Create Group Chat',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        color: green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            rc.isGettingUsersLoading.value
                ? const UsersLoading()
                : rc.allUsers.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 35),
                          Image.asset(
                            'assets/images/empty.png',
                            package: 'robin_flutter',
                            width: 220,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'Nobody Here Yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0XFF535F89),
                            ),
                          ),
                          const SizedBox(height: 13),
                        ],
                      )
                    : rc.isCreatingConversation.value
                        ? const Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  green,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView(
                              children: renderUsers(context),
                            ),
                          )
          ],
        ),
      ),
    );
  }
}
