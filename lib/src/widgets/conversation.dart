import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Conversation extends StatelessWidget {
  final RobinConversation conversation;

  const Conversation({Key? key, required this.conversation}) : super(key: key);

  void doNothing(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        HapticFeedback.selectionClick();
      },
      onTap: () async {
        //TODO: Nav to chat page
      },
      child: Slidable(
        // key: ValueKey(conversation.id),
        endActionPane: ActionPane(
          // dismissible: DismissiblePane(onDismissed: () {}),
          extentRatio: 0.23,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {},
              backgroundColor: green,
              foregroundColor: white,
              icon: Icons.archive,
              label: 'Archive',
            ),
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
          padding: const EdgeInsets.only(top: 12, bottom: 12, left: 15, right: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 45,
                  height: 45,
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
                      conversation.isGroup
                          ? 'assets/icons/people.svg'
                          : 'assets/icons/person.svg',
                      package: 'robin_flutter',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
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
                            conversation.name,
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
                            conversation.lastMessage.text,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: conversation.lastMessage.isAttachment
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
