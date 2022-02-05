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

class RobinAddGroupParticipants extends StatelessWidget {
  final RobinController rc = Get.find();

  final List<String> existingParticipants;

  RobinAddGroupParticipants({
    Key? key,
    required this.existingParticipants,
  }) : super(key: key) {
    rc.getAddGroupUsers(existingParticipants);
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
            if (rc.createGroupParticipants.keys.contains(user.robinToken)) {
              rc.createGroupParticipants.remove(user.robinToken);
            } else {
              rc.createGroupParticipants[user.robinToken] = user.toJson();
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
                const UserAvatar(
                  isGroup: false,
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
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rc.createGroupParticipants.keys
                              .contains(user.robinToken)
                          ? green
                          : null,
                      border: Border.all(
                        width: 2,
                        style: rc.createGroupParticipants.keys
                                .contains(user.robinToken)
                            ? BorderStyle.none
                            : BorderStyle.solid,
                        color: const Color(0xFFBBC1D6),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    users.add(
      const SizedBox(
        height: 100,
      ),
    );
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 45,
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, 15),
            child: Container(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.93,
              decoration: const BoxDecoration(
                color: Color(0XFFEBF3FE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                      () => Container(
                        height: MediaQuery.of(context).size.height - 75,
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
                                        rc.allUsersSearchController.clear();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Add Group Participants',
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
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
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
                                if (rc.createGroupParticipants.length ==
                                    rc.allUsers.length) {
                                  rc.createGroupParticipants.value = {};
                                } else {
                                  Map allUsersMap = {};
                                  for (RobinUser user in rc.allUsers) {
                                    allUsersMap[user.robinToken] =
                                        user.toJson();
                                  }
                                  rc.createGroupParticipants.value =
                                      allUsersMap;
                                }
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
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Select All',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: rc.createGroupParticipants
                                                    .isNotEmpty &&
                                                rc.createGroupParticipants
                                                        .length ==
                                                    rc.allUsers.length
                                            ? green
                                            : const Color(0xFFBBC1D6),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: rc.createGroupParticipants
                                                      .isNotEmpty &&
                                                  rc.createGroupParticipants
                                                          .length ==
                                                      rc.allUsers.length
                                              ? green
                                              : null,
                                          border: Border.all(
                                            width: 2,
                                            style: rc.createGroupParticipants
                                                        .isNotEmpty &&
                                                    rc.createGroupParticipants
                                                            .length ==
                                                        rc.allUsers.length
                                                ? BorderStyle.none
                                                : BorderStyle.solid,
                                            color: const Color(0xFFBBC1D6),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
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
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: green,
                            onPrimary: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: rc.createGroupParticipants.isEmpty
                              ? null
                              : () async {
                                  var successful =
                                      await rc.addGroupParticipants();
                                  if (successful) {
                                    Navigator.pop(context);
                                  }
                                },
                          child: rc.isCreatingGroup.value
                              ? const SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                white),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      'Add Group Participants',
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
