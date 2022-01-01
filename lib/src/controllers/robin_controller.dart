import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/models/robin_user.dart';
import 'package:robin_flutter/src/utils/core.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/models/robin_current_user.dart';
import 'package:robin_flutter/src/models/robin_keys.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RobinController extends GetxController {
  RobinCore? robinCore;
  WebSocketChannel? robinConnection;
  String? apiKey;
  RobinCurrentUser? currentUser;
  Function? getUsers;
  RobinKeys? keys;

  bool robinInitialized = false;

  RxBool isConversationsLoading = true.obs;

  RxBool isGettingUsersLoading = false.obs;
  RxBool createGroup = false.obs;
  RxBool isCreatingConversation = false.obs;
  RxBool isCreatingGroup = false.obs;

  RxBool forwardView = false.obs;

  RxMap createGroupParticipants = {}.obs;

  Map<String, RobinConversation> allConversations = {};

  List<RobinUser> allRobinUsers = [];

  RxList allUsers = [].obs;

  RxList homeConversations = [].obs;
  RxList archivedConversations = [].obs;

  TextEditingController homeSearchController = TextEditingController();

  TextEditingController allUsersSearchController = TextEditingController();

  initializeController(String _apiKey, RobinCurrentUser _currentUser,
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
      allUsersSearchController.addListener(() {
        renderAllUsers();
      });
    }
  }

  getConversations() async {
    try {
      isConversationsLoading.value = true;
      var conversations =
          await robinCore!.getDetailsFromUserToken(currentUser!.robinToken);
      allConversations =
          conversations == null ? {} : toRobinConversations(conversations);
      renderHomeConversations();
      renderArchivedConversations();
      isConversationsLoading.value = false;
    } catch (e) {
      isConversationsLoading.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void renderHomeConversations() {
    List<RobinConversation> conversations = [];
    conversations = allConversations.values
        .where((RobinConversation conversation) =>
            !conversation.archived! &&
            (conversation.name!
                    .toLowerCase()
                    .contains(homeSearchController.text.toLowerCase()) ||
                (!conversation.lastMessage!.isAttachment &&
                    conversation.lastMessage!.text
                        .toLowerCase()
                        .contains(homeSearchController.text.toLowerCase()))))
        .toList();
    homeConversations.value = conversations;
  }

  void renderArchivedConversations() {
    List<RobinConversation> conversations = [];
    conversations = allConversations.values
        .where((RobinConversation conversation) => conversation.archived!)
        .toList();
    archivedConversations.value = conversations;
  }

  Map<String, RobinConversation> toRobinConversations(List conversations) {
    Map<String, RobinConversation> allConversations = {};
    for (Map conversation in conversations) {
      RobinConversation robinConversation =
          RobinConversation.fromJson(conversation);
      allConversations[robinConversation.token ?? robinConversation.id!] =
          robinConversation;
    }
    var sortedEntries = allConversations.entries.toList()
      ..sort((e1, e2) {
        var diff = e2.value.updatedAt!.compareTo(e1.value.updatedAt!);
        if (diff == 0) diff = e2.key.compareTo(e1.key);
        return diff;
      });
    Map<String, RobinConversation> sortedConversations =
        Map<String, RobinConversation>.fromEntries(sortedEntries);
    return sortedConversations;
  }

  void archiveConversation(String conversationId, String key) {
    robinCore!.archiveConversation(conversationId, currentUser!.robinToken);
    allConversations[key]!.archived = true;
    renderHomeConversations();
    renderArchivedConversations();
  }

  void unarchiveConversation(String conversationId, String key) {
    robinCore!.unarchiveConversation(conversationId, currentUser!.robinToken);
    allConversations[key]!.archived = false;
    renderHomeConversations();
    renderArchivedConversations();
  }

  getAllUsers() async {
    try {
      createGroup.value = false;
      createGroupParticipants.value = {};
      isGettingUsersLoading.value = true;
      isCreatingConversation.value = false;
      isCreatingGroup.value = false;
      allUsersSearchController.clear();
      var response = await getUsers!();
      allRobinUsers = [];
      for (Map user in response) {
        String displayName = '';
        String robinToken = '';
        Map displayNameMap = user;
        Map robinTokenMap = user;
        try {
          for (int i = 0; i < keys!.robinToken.length; i++) {
            if (i == keys!.robinToken.length - 1) {
              robinToken = robinTokenMap[keys!.robinToken[i]];
            } else {
              robinTokenMap = robinTokenMap[keys!.robinToken[i]];
            }
          }
        } catch (e) {
          throw "RobinKeys robinToken does not match user model";
        }
        try {
          String separator = keys!.separator ?? " ";
          for (int i = 0; i < keys!.displayName.length; i++) {
            for (int j = 0; j < keys!.displayName[i].length; j++) {
              if (j == keys!.displayName[i].length - 1) {
                displayName +=
                    '${displayNameMap[keys!.displayName[i][j]]}$separator';
              } else {
                displayNameMap = displayNameMap[keys!.displayName[i][j]];
              }
            }
            displayNameMap = user;
          }
          displayName = removeLastSeparator(displayName, separator);
        } catch (e) {
          throw "RobinKeys displayName does not match user model";
        }
        allRobinUsers.add(
          RobinUser(displayName: displayName, robinToken: robinToken),
        );
      }
      allRobinUsers.sort(
        (RobinUser a, RobinUser b) => a.displayName.compareTo(b.displayName),
      );
      renderAllUsers();
      isGettingUsersLoading.value = false;
    } catch (e) {
      isGettingUsersLoading.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  String removeLastSeparator(String str, String separator) {
    str = str.substring(0, str.length - separator.length);
    return str;
  }

  renderAllUsers() {
    allUsers.value = allRobinUsers
        .where((RobinUser user) =>
            user.displayName
                .toLowerCase()
                .contains(allUsersSearchController.text.toLowerCase()) &&
            user.robinToken != currentUser?.robinToken)
        .toList();
  }

  Future<RobinConversation> createConversation(Map<String, String> body) async {
    try {
      isCreatingConversation.value = true;
      body['sender_name'] = currentUser!.fullName;
      body['sender_token'] = currentUser!.robinToken;
      var response = await robinCore!.createConversation(body);
      RobinConversation conversation = RobinConversation.fromJson(response);
      allConversations = {
        conversation.token ?? conversation.id!: conversation,
        ...allConversations,
      };
      renderHomeConversations();
      renderArchivedConversations();
      isCreatingConversation.value = false;
      return conversation;
    } catch (e) {
      isCreatingConversation.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  Future<RobinConversation> createGroupChat(Map body) async {
    try {
      isCreatingGroup.value = true;
      body['participants'] = createGroupParticipants.values.toList();
      body['moderator'] = {'user_token': currentUser!.robinToken};
      var response = await robinCore!.createGroupChat(body);
      RobinConversation conversation = RobinConversation.fromJson(response);
      allConversations = {
        conversation.token ?? conversation.id!: conversation,
        ...allConversations,
      };
      renderHomeConversations();
      renderArchivedConversations();
      isCreatingGroup.value = false;
      return conversation;
    } catch (e) {
      isCreatingGroup.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  initChatView(){
    forwardView.value = false;

  }
}
