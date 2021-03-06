import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/components/user_avatar.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final RobinController rc = Get.find();

  ChatAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  List<String> chatOptions() {
    List<String> options = ['Select Messages'];
    if (rc.currentConversation.value.isGroup!) {
      options.insert(0, 'Group Info');
      options.add('Leave Group');
    } else {
      options.insert(0, 'Contact Info');
      options.add('Delete Conversation');
    }

    return options;
  }

  void confirmLeaveGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: const Color(0XFFF2F2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Leave Group',
                      style: TextStyle(
                        color: black,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        'Are you sure you want to leave the ${rc.currentConversation.value.name} Group',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0XFFB0B0B3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0XFFD53120),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                bool successful = await rc.leaveGroup(
                                    rc.currentConversation.value.id!);
                                if (successful) {
                                  showSuccessMessage('Group left successfully');
                                  rc.allConversations
                                      .remove(rc.currentConversation.value.id!);
                                  if (rc.currentConversation.value.archived!) {
                                    rc.renderArchivedConversations();
                                  } else {
                                    rc.renderHomeConversations();
                                  }
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Proceed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void confirmDeleteConversation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: const Color(0XFFF2F2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Delete Conversation',
                      style: TextStyle(
                        color: black,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        'Are you sure you want to delete your conversation with ${rc.currentConversation.value.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0XFFB0B0B3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0XFFD53120),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                bool successful = await rc.deleteConversation();
                                if (successful) {
                                  showSuccessMessage('Deleted successfully');
                                  rc.allConversations
                                      .remove(rc.currentConversation.value.id!);
                                  if (rc.currentConversation.value.archived!) {
                                    rc.renderArchivedConversations();
                                  } else {
                                    rc.renderHomeConversations();
                                  }
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Proceed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBar(
        backgroundColor: white,
        automaticallyImplyLeading: false,
        title: rc.selectMessageView.value
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      rc.resetChatView();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: black,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    'Select Messages',
                    style: TextStyle(
                      color: black,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: () {
                  showConversationInfo(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      width: 30,
                      child: IconButton(
                        onPressed: () async {
                          rc.handleMessageDraft(
                              rc.currentConversation.value.id!);
                          rc.resetChatView();
                          Navigator.pop(context);
                          rc.renderHomeConversations();
                          rc.renderArchivedConversations();
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Color(0XFF54515C),
                        ),
                      ),
                    ),
                    UserAvatar(
                      name: rc.currentConversation.value.name ?? '',
                      conversationIcon:
                          rc.currentConversation.value.conversationIcon,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  rc.currentConversation.value.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          rc.currentConversation.value.isGroup ?? false
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Obx(
                                          () => Text(
                                            '${rc.currentConversation.value.participants!.length.toString()} Members',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0XFF7A7A7A),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        centerTitle: false,
        actions: [
          rc.selectMessageView.value
              ? InkWell(
                  onTap: rc.selectedMessageIds.isEmpty
                      ? null
                      : () {
                          rc.deleteMessages();
                          rc.resetChatView();
                        },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0, left: 15),
                    child: SvgPicture.asset(
                      'assets/icons/delete.svg',
                      package: 'robin_flutter',
                      width: 22,
                      height: 22,
                    ),
                  ),
                )
              : PopupMenuButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: Color(0XFF54515C),
                  ),
                  enableFeedback: true,
                  elevation: 1,
                  offset: const Offset(0, 60),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'Select Messages') {
                      rc.selectMessageView.value = true;
                    } else if (value == 'Contact Info' ||
                        value == 'Group Info') {
                      showConversationInfo(context);
                    } else if (value == 'Leave Group') {
                      confirmLeaveGroup(context);
                    } else if (value == 'Delete Conversation') {
                      confirmDeleteConversation(context);
                    }
                  },
                  itemBuilder: (context) {
                    List<PopupMenuEntry<Object>> list = [];
                    for (String option in chatOptions()) {
                      list.add(
                        PopupMenuItem(
                          value: option,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option,
                                style: TextStyle(
                                  color: option == 'Leave Group' ||
                                          option == 'Delete Conversation'
                                      ? const Color(0XFFD53120)
                                      : const Color(0XFF51545C),
                                  fontSize: 14,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: SvgPicture.asset(
                                  option == 'Group Info' ||
                                          option == 'Contact Info'
                                      ? 'assets/icons/conversation_info.svg'
                                      : option == 'Select Messages'
                                          ? 'assets/icons/select_messages.svg'
                                          : option == 'Leave Group' ||
                                                  option ==
                                                      'Delete Conversation'
                                              ? 'assets/icons/leave_group.svg'
                                              : '',
                                  package: 'robin_flutter',
                                  width: 22,
                                  height: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (option != chatOptions().last) {
                        list.add(
                          const PopupMenuDivider(
                            height: 2,
                          ),
                        );
                      }
                    }
                    return list;
                  },
                )
        ],
        shadowColor: const Color.fromRGBO(0, 104, 255, 0.125),
      ),
    );
  }
}
