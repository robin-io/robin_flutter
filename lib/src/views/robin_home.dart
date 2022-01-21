import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/views/robin_archived.dart';
import 'package:robin_flutter/src/components/conversations_loading.dart';
import 'package:robin_flutter/src/components/empty_conversation.dart';
import 'package:robin_flutter/src/components/conversation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robin_flutter/src/models/robin_current_user.dart';
import 'package:robin_flutter/src/models/robin_keys.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';

class Robin extends StatelessWidget {
  final String apiKey;
  final RobinCurrentUser currentUser;
  final Function getUsers;
  final RobinKeys keys;

  Robin({
    Key? key,
    required this.apiKey,
    required this.currentUser,
    required this.getUsers,
    required this.keys,
  }) : super(key: key) {
    rc.initializeController(apiKey, currentUser, getUsers, keys);
  }

  final RobinController rc = Get.put(RobinController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        rc.homeSearchController.clear();
        rc.showHomeSearch.value = false;
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: const Color(0XFFFAFAFA),
          appBar: AppBar(
            backgroundColor: white,
            title: !rc.showHomeSearch.value
                ? const Text(
                    'Robin Chat',
                    style: TextStyle(
                      color: black,
                      fontSize: 16,
                    ),
                  )
                : TextFormField(
                    style: const TextStyle(
                      color: Color(0XFF535F89),
                      fontSize: 14,
                    ),
                    cursorColor: const Color(0XFF535F89),
                    controller: rc.homeSearchController,
                    autofocus: true,
                    decoration: textFieldDecoration().copyWith(
                      prefixIcon: SizedBox(
                        width: 22,
                        height: 22,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            semanticsLabel: 'search',
                            package: 'robin_flutter',
                            width: 22,
                            height: 22,
                          ),
                        ),
                      ),
                      hintText: 'Search People...',
                    ),
                  ),
            leadingWidth: 0,
            automaticallyImplyLeading: false,
            actions: rc.showHomeSearch.value
                ? null
                : [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/search_black.svg',
                        semanticsLabel: 'edit',
                        package: 'robin_flutter',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        rc.showHomeSearch.value = true;
                      },
                    )
                  ],
            shadowColor: const Color.fromRGBO(0, 50, 201, 0.2),
            bottom: rc.archivedConversations.isNotEmpty
                ? PreferredSize(
                    preferredSize: const Size(double.infinity, 45),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: InkWell(
                        onTap: () {
                          rc.homeSearchController.clear();
                          rc.showHomeSearch.value = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RobinArchived(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, bottom: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/archive_green.svg',
                                semanticsLabel: 'search',
                                package: 'robin_flutter',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              const Text(
                                'Archived Chats',
                                style: TextStyle(
                                  color: green,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
            centerTitle: false,
          ),
          body: Obx(
            () {
              if (rc.isConversationsLoading.value) {
                return const ConversationsLoading();
              } else if (rc.homeConversations.isEmpty) {
                return const EmptyConversation();
              } else {
                return ListView(
                  children: [
                    for (RobinConversation conversation in rc.homeConversations)
                      Conversation(
                        conversation: conversation,
                      )
                  ],
                );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: green,
              child: SvgPicture.asset(
                'assets/icons/edit.svg',
                semanticsLabel: 'edit',
                package: 'robin_flutter',
                width: 24,
                height: 24,
              ),
              onPressed: () {
                showCreateConversation(context);
              }),
        ),
      ),
    );
  }
}
