import 'package:flutter/material.dart';
import 'package:robin_flutter/src/components/robin_forward_messages.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/components/user_avatar.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final RobinController rc = Get.find();

  ChatAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  List<String> chatOptions() {
    List<String> options = ['Select Messages', 'Chat Info'];
    if (rc.currentConversation!.isGroup!) {
      options.add('Leave Group');
    }
    return options;
  }

  void showForwardMessages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RobinForwardMessages(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBar(
        backgroundColor: white,
        automaticallyImplyLeading: false,
        title: rc.forwardView.value
            ? InkWell(
                onTap: () {
                  rc.resetChatView();
                },
                child: const SizedBox(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0XFF7A7A7A),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    width: 30,
                    child: IconButton(
                      onPressed: () async {
                        rc.resetChatView();
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Color(0XFF535F89),
                      ),
                    ),
                  ),
                  // Container(
                  //   padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                  //   constraints: BoxConstraints(minWidth: 23, maxHeight: 21),
                  //   decoration: BoxDecoration(
                  //     color: Color(0XFF15AE73),
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: Center(
                  //     child: Text(
                  //       '10',
                  //       style: TextStyle(
                  //         fontSize: 15,
                  //         color: white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  UserAvatar(
                    isGroup: rc.currentConversation!.isGroup!,
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
                                rc.currentConversation!.name!,
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
                        rc.currentConversation!.isGroup!
                            ? Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${rc.currentConversation!.participants!.length.toString()} Members',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0XFF7A7A7A),
                                          fontWeight: FontWeight.w400,
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
        centerTitle: false,
        actions: [
          rc.forwardView.value
              ? InkWell(
                  onTap: rc.forwardMessageIds.isEmpty
                      ? null
                      : () {
                          rc.renderForwardConversations();
                          showForwardMessages(context);
                        },
                  child: SizedBox(
                    width: 80,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Text(
                          'Forward',
                          style: TextStyle(
                            color: rc.forwardMessageIds.isEmpty
                                ? const Color(0XFF7A7A7A)
                                : green,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: green,
                  ),
                  enableFeedback: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    ),
                  ),
                  onSelected: (value) async {
                    if (value == 'Select Messages') {
                      rc.forwardView.value = true;
                    } else if (value == 'Chat Info') {
                      //todo: conversation info
                    } else if (value == 'Leave Group') {
                      bool successful =
                          await rc.leaveGroup(rc.currentConversation!.id!);
                      if (successful) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  itemBuilder: (context) {
                    return chatOptions().map((String choice) {
                      return PopupMenuItem(
                        value: choice,
                        child: Text(
                          choice,
                          style: const TextStyle(
                            color: Color(0XFF101010),
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList();
                  },
                )
        ],
        shadowColor: const Color.fromRGBO(0, 104, 255, 0.125),
      ),
    );
  }
}
