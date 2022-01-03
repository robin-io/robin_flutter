import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/widgets/chat_app_bar.dart';
import 'package:robin_flutter/src/widgets/chat_bottom_sheet.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';

class RobinChat extends StatelessWidget {
  final RobinConversation conversation;
  final RobinController rc = Get.find();

  RobinChat({Key? key, required this.conversation}) : super(key: key) {
    rc.initChatView(conversation);
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
      child: Scaffold(
        backgroundColor: white,
        appBar: ChatAppBar(),
        body: Obx(
          () => rc.chatViewLoading.value
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
              : ListView(
                  children: const [Text('E don Finish')],
                ),
        ),
        bottomSheet: ChatBottomSheet(
          bottomPadding: MediaQuery.of(context).padding.bottom,
        ),
      ),
    );
  }
}
