import 'package:flutter/material.dart';
import 'package:robin_flutter/src/components/render_messages.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/components/chat_app_bar.dart';
import 'package:robin_flutter/src/components/chat_bottom_bar.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';

class RobinChat extends StatelessWidget {
  final RobinConversation conversation;
  final RobinController rc = Get.find();

  RobinChat({Key? key, required this.conversation}) : super(key: key) {
    // rc.initChatView(conversation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: white,
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
              rc.forwardView.value
                  ? Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                        top: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: white,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 104, 255, 0.065),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, -2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${rc.forwardMessageIds.length} selected',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: black,
                          ),
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
                  padding: const EdgeInsets.only(bottom: 75),
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
