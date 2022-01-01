import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/widgets/user_avatar.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:get/get.dart';

class RobinChat extends StatelessWidget {
  final RobinConversation conversation;
  final RobinController rc = Get.find();

  RobinChat({Key? key, required this.conversation}) : super(key: key) {
    rc.initChatView();
  }

  List<String> chatOptions() {
    List<String> options = ['Select Messages'];
    if (conversation.isGroup!) {
      options.add('Leave Group');
      options.add('Group Info');
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //todo: reimplement remove focus
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: white,
            automaticallyImplyLeading: false,
            title: rc.forwardView.value
                ? InkWell(
                    onTap: () {
                      rc.initChatView();
                    },
                    child: const SizedBox(
                      width: 73,
                      child: Center(
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
                          onPressed: () {
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
                      //         color: Color(0XFFFFFFFF),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      UserAvatar(
                        isGroup: conversation.isGroup!,
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
                                    conversation.name!,
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
                            conversation.isGroup!
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${conversation.participants!.length.toString()} Members',
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
                      onTap: () {
                        // if (_selectedMessages.isNotEmpty) {
                        //   _showForwardModal(widget.getConversations());
                        // }
                      },
                      child: const SizedBox(
                        width: 80,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Text(
                              'Forward',
                              style: TextStyle(
                                color: green,
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
                        }
                        // else if (value == 'Leave Group') {
                        //   setState(() {
                        //     _showSpinner = true;
                        //   });
                        //   await robin.removeGroupParticipant(
                        //       widget.conversation['_id'],
                        //       widget.user['robinToken']);
                        //   widget.callback();
                        //   Navigator.pop(context);
                        // }
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
            shadowColor: const Color.fromRGBO(0, 104, 255, 0.2),
          ),
          body: Text(conversation.name!),
        ),
      ),
    );
  }
}
