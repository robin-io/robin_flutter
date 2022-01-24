import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:robin_flutter/src/models/robin_message.dart';
import 'dart:convert';
import 'package:robin_flutter/src/models/robin_user.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/core.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/models/robin_current_user.dart';
import 'package:robin_flutter/src/models/robin_keys.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
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
  RxBool isCreatingConversation = false.obs;
  RxBool isCreatingGroup = false.obs;
  RxBool finishedInitialScroll = false.obs;

  RxBool selectMessageView = false.obs;
  RxBool replyView = false.obs;
  RxBool chatViewLoading = false.obs;
  RxBool showSendButton = false.obs;
  RxBool isFileSending = false.obs;
  RxBool atMaxScroll = false.obs;

  RxBool isForwarding = false.obs;

  OverlayEntry? chatOptionsEntry;
  RxBool chatOptionsOpened = false.obs;

  RxList selectedMessageIds = [].obs;

  RobinConversation? currentConversation;

  RxString selectedConversation = ''.obs;

  RobinMessage? replyMessage;

  Map userColors = {};

  RxMap conversationMessages = {}.obs;

  RxMap file = {}.obs;

  final ScrollController messagesScrollController = ScrollController();

  RxMap createGroupParticipants = {}.obs;

  Map<String, RobinConversation> allConversations = {};

  List<RobinUser> allRobinUsers = [];

  RxList allUsers = [].obs;

  RxList homeConversations = [].obs;
  RxList archivedConversations = [].obs;

  RxList forwardConversations = [].obs;

  RxList forwardConversationIds = [].obs;

  RxBool showHomeSearch = false.obs;

  RxBool groupChatNameEmpty = true.obs;

  TextEditingController homeSearchController = TextEditingController();
  TextEditingController archiveSearchController = TextEditingController();

  TextEditingController allUsersSearchController = TextEditingController();

  TextEditingController forwardController = TextEditingController();

  TextEditingController messageController = TextEditingController();

  TextEditingController groupChatNameController = TextEditingController();

  void initializeController(String _apiKey, RobinCurrentUser _currentUser,
      Function _getUsers, RobinKeys _keys) {
    robinCore ??= RobinCore();
    apiKey ??= _apiKey;
    currentUser ??= _currentUser;
    getUsers ??= _getUsers;
    keys ??= _keys;
    robinConnection ??= robinCore!.connect(apiKey, currentUser!.robinToken);
    robinCore!.subscribe();
    if (!robinInitialized) {
      robinInitialized = true;
      getConversations();
      connectionStartListen();
      homeSearchController.addListener(() {
        renderHomeConversations();
      });
      archiveSearchController.addListener(() {
        renderArchivedConversations();
      });
      allUsersSearchController.addListener(() {
        renderAllUsers();
      });
      messageController.addListener(() {
        showSendButton.value = messageController.text.isNotEmpty;
      });
      forwardController.addListener(() {
        renderForwardConversations();
      });
      groupChatNameController.addListener(() {
        groupChatNameEmpty.value = groupChatNameController.text.isEmpty;
      });
    }
  }

  connectionStartListen() {
    robinConnection!.stream.listen((data) {
      data = json.decode(data);

      print(data);
      if (data['is_event'] == null || data['is_event'] == false) {
        RobinMessage robinMessage = RobinMessage.fromJson(data);
        if (robinMessage.conversationId == currentConversation!.id!) {
          conversationMessages[robinMessage.id] = robinMessage;
        }
        //todo: set conversation last message
        if (!robinMessage.sentByMe) {
          FlutterRingtonePlayer.playNotification();
        }
        if (!currentConversation!.isGroup! &&
            robinMessage.conversationId == currentConversation!.id! &&
            !robinMessage.sentByMe) {
          sendReadReceipts([robinMessage.id]);
        }
        if (atMaxScroll.value) {
          Future.delayed(const Duration(milliseconds: 17), () {
            scrollToEnd();
          });
        }
      } else {
        switch (data['name']) {
          case 'message.forward':
            handleMessageForward(data['value']);
            break;
          case 'delete.message':
            handleDeleteMessages(data['value']['ids']);
            break;
          case 'read.reciept':
            if (currentConversation!.id! == data['value']['conversation_id']) {
              for (String messageId in data['value']['message_ids']) {
                if (conversationMessages[messageId] != null) {
                  conversationMessages[messageId].isRead = true;
                  conversationMessages[messageId] =
                      conversationMessages[messageId];
                }
              }
            }
            break;
          default:
            //cannot handle event
            break;
        }
      }
    });
  }

  handleMessageForward(List messages) {
    for (Map message in messages) {
      RobinMessage robinMessage = RobinMessage.fromJson(message);
      if (robinMessage.conversationId == currentConversation!.id!) {
        conversationMessages[robinMessage.id] = robinMessage;
      }
      if (!robinMessage.sentByMe) {
        FlutterRingtonePlayer.playNotification();
      }
      if (!currentConversation!.isGroup! &&
          robinMessage.conversationId == currentConversation!.id! &&
          !robinMessage.sentByMe) {
        sendReadReceipts([robinMessage.id]);
      }
      if (atMaxScroll.value) {
        Future.delayed(const Duration(milliseconds: 17), () {
          scrollToEnd();
        });
      }
    }
    //todo: set conversation last message
  }

  scrollToEnd() {
    messagesScrollController.animateTo(
      messagesScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  void getConversations() async {
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
        .where((RobinConversation conversation) =>
            conversation.archived! &&
            (conversation.name!
                    .toLowerCase()
                    .contains(archiveSearchController.text.toLowerCase()) ||
                (!conversation.lastMessage!.isAttachment &&
                    conversation.lastMessage!.text
                        .toLowerCase()
                        .contains(archiveSearchController.text.toLowerCase()))))
        .toList();
    archivedConversations.value = conversations;
  }

  void renderForwardConversations() {
    List<RobinConversation> conversations = [];
    conversations = allConversations.values
        .where((RobinConversation conversation) => conversation.name!
            .toLowerCase()
            .contains(forwardController.text.toLowerCase()))
        .toList();
    forwardConversations.value = conversations;
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

  void getAllUsers() async {
    try {
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

  void renderAllUsers() {
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

  Future<RobinConversation> createGroupChat() async {
    try {
      isCreatingGroup.value = true;
      Map<String, dynamic> body = {};
      body['name'] = groupChatNameController.text;
      body['participants'] = createGroupParticipants.values.toList();
      body['moderator'] = {
        'user_token': currentUser!.robinToken,
        'meta_data': {'displayName': currentUser!.fullName}
      };
      var response = await robinCore!.createGroupChat(body);
      print(response);
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

  void initChatView(RobinConversation conversation) {
    resetChatView();
    rc.homeSearchController.clear();
    rc.showHomeSearch.value = false;
    userColors = {};
    messageController.clear();
    finishedInitialScroll.value = false;
    currentConversation = conversation;
    if (currentConversation!.isGroup!) {
      generateUserColors();
    }
    getMessages();
  }

  void resetChatView() {
    selectMessageView.value = false;
    selectedMessageIds.value = [].obs;
    forwardConversations.value = [].obs;
    forwardConversationIds.value = [].obs;
    isForwarding.value = false;
    file['file'] = null;
    replyView.value = false;
    replyMessage = null;
    chatViewLoading.value = false;
  }

  void generateUserColors() {
    List<Color> colors = groupUserColors.toList();
    for (Map user in currentConversation!.participants!) {
      if (colors.length < 2) {
        colors = groupUserColors.toList();
      }
      userColors[user['user_token']] = (colors.toList()..shuffle()).first;
      colors.remove(userColors[user['user_token']]);
    }
    userColors[currentUser!.robinToken] = green;
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      chatViewLoading.value = true;
      Map<String, String> body = {
        'user_token': currentUser!.robinToken,
      };
      await robinCore!.removeGroupParticipant(body, groupId);
      chatViewLoading.value = false;
      return true;
    } catch (e) {
      chatViewLoading.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void getMessages() async {
    try {
      chatViewLoading.value = true;
      var response = await robinCore!.getConversationMessages(
        currentConversation!.id!,
        currentUser!.robinToken,
      );
      conversationMessages.value = toRobinMessage(response ?? []);
      chatViewLoading.value = false;
    } catch (e) {
      chatViewLoading.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  Map<String, RobinMessage> toRobinMessage(List messages) {
    Map<String, RobinMessage> allMessages = {};
    List<String> unreadMessages = [];
    for (Map message in messages) {
      RobinMessage robinMessage = RobinMessage.fromJson(message);
      if (!robinMessage.isRead && !robinMessage.sentByMe) {
        unreadMessages.add(robinMessage.id);
      }
      allMessages[robinMessage.id] = robinMessage;
    }
    if (unreadMessages.isNotEmpty && !currentConversation!.isGroup!) {
      sendReadReceipts(unreadMessages);
    }
    return allMessages;
  }

  void sendTextMessage() {
    try {
      if (messageController.text.isNotEmpty) {
        Map<String, String> message = {
          'msg': messageController.text,
          'timestamp': DateTime.now().toString(),
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
        };
        robinCore!.sendTextMessage(
          currentConversation!.id!,
          message,
          currentUser!.robinToken,
          currentUser!.fullName,
        );
        messageController.clear();
      }
    } catch (e) {
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void sendReplyAsTextMessage() {
    try {
      if (messageController.text.isNotEmpty) {
        Map<String, String> message = {
          'msg': messageController.text,
          'timestamp': DateTime.now().toString(),
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
        };
        robinCore!.replyToMessage(
          message,
          currentConversation!.id!,
          replyMessage!.id,
          currentUser!.robinToken,
          currentUser!.fullName,
        );
        messageController.clear();
        replyMessage = null;
        replyView.value = false;
      }
    } catch (e) {
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void sendAttachment() async {
    try {
      if (file['file'] != null) {
        isFileSending.value = true;
        Map<String, String> body = {
          'conversation_id': currentConversation!.id!,
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
        };
        List<http.MultipartFile> files = [
          await http.MultipartFile.fromPath(
            'file',
            file['file'].path,
          ),
        ];
        await robinCore!.sendAttachment(body, files);
        file['file'] = null;
        isFileSending.value = false;
      }
    } catch (e) {
      isFileSending.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void sendReplyAsAttachment() async {
    try {
      if (file['file'] != null) {
        isFileSending.value = true;
        Map<String, String> body = {
          'conversation_id': currentConversation!.id!,
          'message_id': replyMessage!.id,
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
        };
        List<http.MultipartFile> files = [
          await http.MultipartFile.fromPath(
            'file',
            file['file'].path,
          ),
        ];
        await robinCore!.replyWithAttachment(body, files);
        file['file'] = null;
        isFileSending.value = false;
        replyMessage = null;
        replyView.value = false;
      }
    } catch (e) {
      isFileSending.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  forwardMessages() async {
    try {
      isForwarding.value = true;
      Map<String, dynamic> body = {
        'user_token': currentUser!.robinToken,
        'message_ids': selectedMessageIds.toList(),
        'conversation_ids': forwardConversationIds.toList(),
      };
      await robinCore!.forwardMessages(body);
      resetChatView();
    } catch (e) {
      isForwarding.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void sendReadReceipts(List<String> messageIds) async {
    Map<String, dynamic> body = {
      'conversation_id': currentConversation!.id!,
      'message_ids': messageIds,
    };
    robinCore!.sendReadReceipts(body);
  }

  void deleteMessages() {
    Map<String, dynamic> body = {
      'ids': selectedMessageIds.toList(),
      'requester_token': currentUser!.robinToken,
    };
    handleDeleteMessages(selectedMessageIds.toList());
    robinCore!.deleteMessages(body);
  }

  void handleDeleteMessages(List messageIds) {
    for (String messageId in messageIds) {
      conversationMessages.remove(messageId);
    }
  }

  void sendReaction(String reaction, String messageId) async {
    Map<String, dynamic> body = {
      'user_token': currentUser!.robinToken,
      'reaction': reaction,
      'conversation_id': currentConversation!.id,
      'timestamp': getTimestamp(),
    };
    conversationMessages[messageId] =
        RobinMessage.fromJson(await robinCore!.sendReaction(body, messageId));
  }

  void removeReaction(String messageId, String reactionId) async {
    conversationMessages[messageId] = RobinMessage.fromJson(
        await robinCore!.removeReaction(messageId, reactionId));
  }
}
