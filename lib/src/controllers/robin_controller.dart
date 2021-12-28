import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/utils/core.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/models/robin_user.dart';
import 'package:robin_flutter/src/models/robin_keys.dart';
import 'package:robin_flutter/src/widgets/conversation.dart';
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

  RxList renderedConversations = [].obs;

  TextEditingController searchController = TextEditingController();

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
      searchController.addListener(() {
        filterAllConversations();
        renderConversations();
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
      renderConversations();
      isConversationsLoading(false);
    } catch (e) {
      isConversationsLoading(false);
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  RxList renderConversations() {
    renderedConversations = [].obs;
    for (RobinConversation conversation in allConversations) {
      if (!conversation.archived) {
        renderedConversations.add(
          Conversation(
            conversation: conversation,
          ),
        );
      }
    }
    print(renderedConversations.length);
    return renderedConversations;
  }

  filterAllConversations() {
    List<RobinConversation> conversations = [];
    for (RobinConversation conversation in allConversations) {
      if (conversation.name.contains(searchController.text)) {
        conversations.add(conversation);
      }
    }
    allConversations = conversations;
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
}
