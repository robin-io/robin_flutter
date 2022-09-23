import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:robin_flutter/src/views/robin_chat.dart';
import 'package:robin_flutter/src/components/user_avatar.dart';

class Conversation extends StatelessWidget {
  final RobinConversation conversation;

  Conversation({Key? key, required this.conversation}) : super(key: key);

  final RobinController rc = Get.find();

  void handleArchive(BuildContext context) {
    if (conversation.archived!) {
      rc.unarchiveConversation(conversation.id!, conversation.id!);
    } else {
      rc.archiveConversation(conversation.id!, conversation.id!);
    }
  }

  void deleteConversation(BuildContext context) {
    rc.allConversations.remove(conversation.id);
    if (conversation.archived!) {
      rc.renderArchivedConversations();
    } else {
      rc.renderHomeConversations();
    }
    rc.deleteConversation(conversationId: conversation.id, showLoader: false);
  }

  void leaveGroup(BuildContext context) {
    rc.allConversations.remove(conversation.id);
    if (conversation.archived!) {
      rc.renderArchivedConversations();
    } else {
      rc.renderHomeConversations();
    }
    rc.leaveGroup(conversation.id!, showLoader: false);
  }

  List<PopupMenuItem<int>> getMenuItems() {
    List<PopupMenuItem<int>> menuItems = [
      PopupMenuItem<int>(
        padding: const EdgeInsets.only(left: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              conversation.archived! ? 'Unarchive' : 'Archive',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0XFF101010),
              ),
            ),
            SizedBox(
              width: conversation.isGroup! ? 45 : 90,
            ),
            SvgPicture.asset(
              'assets/icons/archive_black.svg',
              semanticsLabel: 'archive',
              package: 'robin_flutter',
              width: 22,
              height: 22,
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        value: 1,
      ),
      // PopupMenuItem<int>(
      //   padding: const EdgeInsets.only(left: 15),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Text(
      //         conversation.archived! ? 'Pin' : 'Pin',
      //         style: const TextStyle(
      //           fontSize: 14,
      //           color: Color(0XFF101010),
      //         ),
      //       ),
      //       const SizedBox(
      //         width: 90,
      //       ),
      //       const Icon(Icons.pin_drop),
      //       const SizedBox(
      //         width: 10,
      //       ),
      //     ],
      //   ),
      //   value: 2,
      // ),
    ];
    if (rc.canDeleteConversations) {
      menuItems.add(
        PopupMenuItem<int>(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                conversation.isGroup! ? 'Leave Group' : 'Delete Conversation',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0XFF101010),
                ),
              ),
              const SizedBox(
                width: 23,
              ),
              SvgPicture.asset(
                'assets/icons/delete.svg',
                semanticsLabel: 'delete',
                package: 'robin_flutter',
                width: 22,
                height: 22,
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          value: 3,
        ),
      );
    }
    return menuItems;
  }

  void showPopupMenu(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    double width = renderBox.size.width;
    double height = renderBox.localToGlobal(Offset.zero).dy;
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(width, height + 75, 0, 0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
      ),
      items: getMenuItems(),
      elevation: 4,
    ).then((value) {
      rc.selectedConversation.value = '';
      if (value == 1) {
        handleArchive(context);
      } else if (value == 2) {
        //pin
      } else if (value == 3) {
        if (conversation.isGroup!) {
          leaveGroup(context);
        } else {
          deleteConversation(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        HapticFeedback.selectionClick();
        rc.selectedConversation.value = conversation.id!;
        showPopupMenu(context);
      },
      onTap: () async {
        rc.homeSearchController.clear();
        rc.showHomeSearch.value = false;
        rc.allConversations[conversation.id]?.unreadMessages = 0;
        rc.allConversations[conversation.id!] =
            rc.allConversations[conversation.id]!;
        if (rc.allConversations[conversation.id!]!.archived!) {
          rc.renderArchivedConversations();
        } else {
          rc.renderHomeConversations();
        }
        updateLocalConversations();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RobinChat(
              conversation: conversation,
            ),
          ),
        ).then((value) {
          Future.delayed(const Duration(milliseconds: 100), () {
            rc.currentConversation.value = RobinConversation.empty();
            rc.conversationMessages.value = {};
          });
        });
      },
      child: Slidable(
        key: ValueKey(conversation.id),
        startActionPane: ActionPane(
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
        endActionPane: ActionPane(
          extentRatio: 0.23,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed:
                  conversation.isGroup! ? leaveGroup : deleteConversation,
              backgroundColor: const Color(0XFFD53120),
              autoClose: true,
              foregroundColor: white,
              icon: Icons.delete,
            )
          ],
        ),
        closeOnScroll: true,
        child: Container(
          decoration: const BoxDecoration(
            color: white,
            border: Border(
              bottom: BorderSide(
                width: 3,
                style: BorderStyle.solid,
                color: Color(0XFFF5F7FC),
              ),
            ),
          ),
          padding:
              const EdgeInsets.only(top: 12, bottom: 12, left: 15, right: 15),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(
                    name: conversation.name!,
                    imageUrl: conversation.conversationIcon,
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
                                  color: black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Center(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversation.lastMessage!.text.isEmpty
                                      ? 'New Conversation'
                                      : !conversation.isGroup! &&
                                              !conversation
                                                  .lastMessage!.sentByMe
                                          ? conversation.lastMessage!.text
                                          : '${conversation.lastMessage!.senderName}${conversation.lastMessage!.text}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        conversation.lastMessage!.isAttachment
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color: const Color(0XFF8D9091),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  conversation.unreadMessages! > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatDate(conversation.updatedAt.toString()),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0XFF51545C),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: robinOrange,
                              ),
                              child: Center(
                                child: Text(
                                  conversation.unreadMessages! > 9
                                      ? '9+'
                                      : '${conversation.unreadMessages}',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          formatDate(conversation.updatedAt.toString()),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0XFF51545C),
                          ),
                        ),
                ],
              ),
              SizedBox(
                height: 45,
                child: Obx(
                  () => BackdropFilter(
                    filter: rc.selectedConversation.value.isNotEmpty &&
                            rc.selectedConversation.value != conversation.id!
                        ? ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(
                      height: 45,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
