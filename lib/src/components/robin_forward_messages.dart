import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/components/robin_create_group.dart';
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
                  name: conversation.name!,
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
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rc.forwardConversationIds.contains(conversation.id)
                          ? green
                          : null,
                      border: Border.all(
                        width: 2,
                        style:
                            rc.forwardConversationIds.contains(conversation.id)
                                ? BorderStyle.none
                                : BorderStyle.solid,
                        color: const Color(0xFFBBC1D6),
                      ),
                    ),
                    child: rc.forwardConversationIds.contains(conversation.id)
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: white,
                            ),
                          )
                        : Container(),
                  ),
                )
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
    return SizedBox(
      height: MediaQuery.of(context).size.height - 70,
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
                    Container(
                      height: MediaQuery.of(context).size.height - 100,
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
                                  'Forward Messages',
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
                          Expanded(
                            child: Obx(
                              () => ListView(
                                children: renderConversations(),
                              ),
                            ),
                          )
                        ],
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
                          onPressed: rc.forwardConversationIds.isEmpty
                              ? null
                              : () async {
                                  await rc.forwardMessages();
                                  Navigator.pop(context);
                                },
                          child: rc.isForwarding.value
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
                                      'Forward',
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
