import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/views/robin_chat.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:robin_flutter/src/components/user_avatar.dart';

class RobinCreateGroup extends StatelessWidget {
  RobinCreateGroup({Key? key}) : super(key: key);

  final RobinController rc = Get.find();

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
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color(0XFFF1F1F1),
                                ),
                              ),
                            ),
                            child: Padding(
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
                                        rc.groupChatNameController.clear();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'New Group Chat',
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Obx(
                              () => Container(
                                width: 80,
                                height: 80,
                                color: const Color(0XFF9999BC),
                                child: rc.groupIcon.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'RG',
                                          style: TextStyle(
                                            color: white,
                                            fontSize: 24,
                                          ),
                                        ),
                                      )
                                    : Image.file(
                                        File(rc.groupIcon['file'].path),
                                        fit: BoxFit.cover,
                                        height: 80,
                                        width: 80,
                                      ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              getMedia(source: 'gallery', isGroup: true);
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                              child: const Text(
                                'Tap To Add Group Image',
                                style: TextStyle(
                                  color: black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
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
                              controller: rc.groupChatNameController,
                              decoration: textFieldDecoration().copyWith(
                                hintText: 'Type a group chat name',
                              ),
                            ),
                          ),
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
                          onPressed: rc.groupChatNameEmpty.value
                              ? null
                              : () {
                                  showSelectGroupParticipants(context);
                                },
                          child: const SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Continue',
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
