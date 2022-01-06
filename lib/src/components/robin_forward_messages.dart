import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/views/robin_create_group.dart';
import 'package:robin_flutter/src/components/user_avatar.dart';
import 'package:robin_flutter/src/components/users_loading.dart';

class RobinForwardMessages extends StatelessWidget {
  final RobinController rc = Get.find();

  RobinForwardMessages({Key? key}) : super(key: key);

  List<Widget> renderConversations() {
    List<Widget> conversations = [];
    for (RobinConversation conversation in rc.forwardConversations) {
      conversations.add(
        InkWell(
          onTap: () async {
            if (rc.forwardConversationIds.contains(conversation.id)) {
              rc.forwardConversationIds.remove(conversation.id);
            } else {
              rc.forwardConversationIds.add(conversation.id);
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                  color: Color(0XFFF4F6F8),
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
                  isGroup: conversation.isGroup!,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    conversation.name!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0XFF000000),
                    ),
                  ),
                ),
                rc.createGroup.value
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rc.forwardConversationIds
                                    .contains(conversation.id)
                                ? green
                                : null,
                            border: Border.all(
                              width: 2,
                              style: rc.forwardConversationIds
                                      .contains(conversation.id)
                                  ? BorderStyle.none
                                  : BorderStyle.solid,
                              color: const Color(0xFFBBC1D6),
                            ),
                          ),
                          child: Center(
                            child: rc.createGroup.value
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : Container(),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      );
    }
    return conversations;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        closeButton(context),
        Obx(
          () => Container(
            height: MediaQuery.of(context).size.height - 110,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      rc.createGroup.value
                          ? const Text(
                              'Done',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.transparent,
                              ),
                            )
                          : Container(),
                      Container(
                        width: 45,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0XFFF4F6F8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      rc.createGroup.value
                          ? InkWell(
                              onTap: rc.createGroupParticipants.isNotEmpty
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RobinCreateGroup(),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(
                                'Done',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: rc.createGroupParticipants.isNotEmpty
                                      ? green
                                      : Colors.grey,
                                ),
                              ),
                            )
                          : Container(height: 19),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: TextFormField(
                    style: const TextStyle(
                      color: Color(0XFF535F89),
                      fontSize: 14,
                    ),
                    controller: rc.allUsersSearchController,
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
                !rc.createGroup.value
                    ? InkWell(
                        onTap: () {
                          rc.createGroup.value = true;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: Color(0XFFF4F6F8),
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.only(top: 12, bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0XFFF4F6F8),
                                    border: Border.all(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      color: const Color(0XFFCADAF8),
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/people.svg',
                                      package: 'robin_flutter',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Create A New Group',
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
                      )
                    : const SizedBox(height: 20),
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
                                  children: renderConversations(),
                                ),
                              )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
