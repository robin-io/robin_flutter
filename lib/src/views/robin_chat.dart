import 'package:flutter/material.dart';
import 'package:robin_flutter/src/components/render_messages.dart';
import 'package:robin_flutter/src/components/robin_forward_messages.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/components/chat_app_bar.dart';
import 'package:robin_flutter/src/components/chat_bottom_bar.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';

class RobinChat extends StatelessWidget {
  final RobinConversation conversation;
  final bool? newUser;
  final RobinController rc = Get.find();

  RobinChat({
    Key? key,
    required this.conversation,
    this.newUser
  }) : super(key: key) {
    rc.initChatView(conversation, newUser ?? false);
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: const Color(0xFFF5F7FC),
          appBar: ChatAppBar(),
          body: Column(
            children: [
              Expanded(
                child: rc.chatViewLoading.value
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
                    : RenderMessages(),
              ),
              rc.selectMessageView.value
                  ? Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                        top: 20,
                      ),
                      color: white,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rc.selectedMessageIds.length == 1
                                  ? '${rc.selectedMessageIds.length} Message Selected'
                                  : '${rc.selectedMessageIds.length} Messages Selected',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0XFF51545C),
                              ),
                            ),
                            rc.canForwardMessages ? InkWell(
                              onTap: rc.selectedMessageIds.isEmpty
                                  ? null
                                  : () {
                                      rc.renderForwardConversations();
                                      showForwardMessages(context);
                                    },
                              child: SizedBox(
                                width: 80,
                                height: 25,
                                child: Center(
                                  child: Text(
                                    'Forward',
                                    style: TextStyle(
                                      color: rc.selectedMessageIds.isEmpty
                                          ? const Color(0XFF7A7A7A)
                                          : green,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ) : Container()
                          ],
                        ),
                      ),
                    )
                  : ChatBottomBar(
                      bottomPadding: MediaQuery.of(context).padding.bottom,
                    ),
            ],
          ),
          floatingActionButton: rc.chatViewLoading.value || rc.atMaxScroll.value
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 105),
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: FloatingActionButton(
                      onPressed: () {
                        rc.scrollToEnd();
                      },
                      backgroundColor: white,
                      elevation: 5,
                      child: const Icon(
                        Icons.arrow_downward,
                        size: 18,
                        color: green,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

}
