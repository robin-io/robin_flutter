import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/views/robin_chat.dart';
import 'package:robin_flutter/src/views/robin_home.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/widgets/user_avatar.dart';

class RobinCreateGroup extends StatelessWidget {
  RobinCreateGroup({Key? key}) : super(key: key);

  final RobinController rc = Get.find();

  final TextEditingController groupNameController = TextEditingController();

  List<Widget> renderUsers(BuildContext context) {
    List<Widget> users = [];
    rc.createGroupParticipants.forEach((key, user) {
      users.add(
        Container(
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
              const UserAvatar(
                isGroup: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user['meta_data']['display_name'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0XFF000000),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  rc.createGroupParticipants.remove(user['user_token']);
                  if (rc.createGroupParticipants.isEmpty) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.clear,
                  size: 18,
                  color: Color(0xFF6B7491),
                ),
              )
            ],
          ),
        ),
      );
    });
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        shadowColor: const Color.fromRGBO(0, 104, 255, 0.15),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 121),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  closeButton(context),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: rc.isCreatingGroup.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  green,
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () async {
                                if (groupNameController.text.isEmpty) {
                                  showErrorMessage(
                                      'Please type in a group name');
                                } else if (rc.createGroupParticipants.isEmpty) {
                                  showErrorMessage(
                                      'Please select participants for this group');
                                  Navigator.pop(context);
                                } else {
                                  Map body = {
                                    'name': groupNameController.text,
                                  };
                                  RobinConversation conversation =
                                      await rc.createGroupChat(body);
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            RobinChat(
                                          conversation: conversation,
                                        ),
                                      ),
                                      (route) => route is Robin);
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                                child: Text(
                                  'Create Group',
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Group Name',
                    style: TextStyle(
                      color: black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                child: TextFormField(
                  style: const TextStyle(
                    color: Color(0XFF535F89),
                    fontSize: 14,
                  ),
                  controller: groupNameController,
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'Type a group chat name',
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                rc.createGroupParticipants.keys.length == 1
                    ? '${rc.createGroupParticipants.keys.length} Member'
                    : '${rc.createGroupParticipants.keys.length} Members',
                style: const TextStyle(
                  color: Color(0XFF7A7A7A),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView(
                children: renderUsers(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}
