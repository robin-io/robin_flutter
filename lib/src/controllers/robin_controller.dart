import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/utils/core.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/models/robin_user.dart';
import 'package:robin_flutter/src/models/robin_keys.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RobinController extends GetxController {
  RobinCore? robinCore;
  WebSocketChannel? robinConnection;
  String? apiKey;
  RobinUser? currentUser;
  Function? getUsers;
  RobinKeys? keys;

  bool robinInitialized = false;

  RxBool isConversationsLoading = true.obs;

  List<RobinConversation> allConversations = [];

  RxList homeConversations = [].obs;
  RxList archivedConversations = [].obs;

  TextEditingController homeSearchController = TextEditingController();

  initializeController(String _apiKey, RobinUser _currentUser,
      Function _getUsers, RobinKeys _keys) {
    robinCore ??= RobinCore();
    apiKey ??= _apiKey;
    currentUser ??= _currentUser;
    getUsers ??= _getUsers;
    keys ??= _keys;
    robinConnection ??= robinCore!.connect(apiKey, currentUser!.robinToken);
    if (!robinInitialized) {
      robinInitialized = true;
      getConversations();
      homeSearchController.addListener(() {
        renderHomeConversations();
      });
    }
  }

  getConversations() async {
    try {
      isConversationsLoading(true);
      var conversations =
          await robinCore!.getDetailsFromUserToken(currentUser!.robinToken);
      allConversations =
          conversations == null ? [] : toRobinConversations(conversations);
      renderHomeConversations();
      renderArchivedConversations();
      isConversationsLoading(false);
    } catch (e) {
      isConversationsLoading(false);
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void renderHomeConversations() {
    List<RobinConversation> conversations = [];
    conversations = allConversations
        .where((RobinConversation conversation) =>
            !conversation.archived &&
                (conversation.name
                    .toLowerCase()
                    .contains(homeSearchController.text.toLowerCase())) ||
            (!conversation.lastMessage.isAttachment &&
                conversation.lastMessage.text
                    .toLowerCase()
                    .contains(homeSearchController.text.toLowerCase())))
        .toList();
    homeConversations.value = conversations;
  }

  void renderArchivedConversations() {
    List<RobinConversation> conversations = [];
    conversations = allConversations
        .where((RobinConversation conversation) => conversation.archived)
        .toList();
    archivedConversations.value = conversations;
  }

  List<RobinConversation> toRobinConversations(List conversations) {
    List<RobinConversation> allConversations = [];
    for (Map conversation in conversations) {
      allConversations.add(RobinConversation.fromJson(conversation));
    }
    allConversations.sort((a, b) {
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return allConversations;
  }

  void archiveConversation(String conversationId){

  }
}
