import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:robin_flutter/src/views/robin_chat.dart';
import 'package:robin_flutter/src/widgets/user_avatar.dart';

class Conversation extends StatelessWidget {
  final RobinConversation conversation;

  Conversation({Key? key, required this.conversation}) : super(key: key);

  final RobinController rc = Get.find();

  void handleArchive(BuildContext context) {
    if (conversation.archived!) {
      rc.unarchiveConversation(
          conversation.id!, conversation.token ?? conversation.id!);
    } else {
      rc.archiveConversation(
          conversation.id!, conversation.token ?? conversation.id!);
    }
  }

  void showPopupMenu(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    double width = renderBox.size.width;
    double height = renderBox.localToGlobal(Offset.zero).dy;
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(width, height, 0, 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24.0),
        ),
      ),
      items: [
        PopupMenuItem<int>(
          child: SizedBox(
            width: 95,
            child: Text(
              conversation.archived! ? 'Unarchive' : 'Archive',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0XFF101010),
              ),
            ),
          ),
          value: 1,
        ),
      ],
      elevation: 4,
    ).then((value) {
      if (value == 1) {
        handleArchive(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        HapticFeedback.selectionClick();
        showPopupMenu(context);
      },
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RobinChat(
              conversation: conversation,
            ),
          ),
        );
      },
      child: Slidable(
        key: ValueKey(conversation.id),
        endActionPane: ActionPane(
          dismissible: DismissiblePane(
            onDismissed: () {
              handleArchive(context);
            },
          ),
          extentRatio: 0.23,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: handleArchive,
              backgroundColor: green,
              autoClose: true,
              foregroundColor: white,
              icon: conversation.archived! ? Icons.unarchive : Icons.archive,
            )
          ],
        ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
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
                        Text(
                          formatDate(conversation.updatedAt.toString()),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0XFF566BA0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage!.text,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: conversation.lastMessage!.isAttachment
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: const Color(0XFF7A7A7A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
