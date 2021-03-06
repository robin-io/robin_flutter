import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:robin_flutter/src/models/robin_last_message.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/models/robin_message_reaction.dart';
import 'dart:convert';
import 'package:robin_flutter/src/models/robin_user.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/extensions.dart';
import 'package:uuid/uuid.dart';
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

  final uuid = const Uuid();

  RxBool isConversationsLoading = true.obs;

  RxBool isGettingUsersLoading = false.obs;
  RxBool isCreatingConversation = false.obs;
  RxBool isCreatingGroup = false.obs;

  RxBool selectMessageView = false.obs;
  RxBool replyView = false.obs;
  RxBool chatViewLoading = false.obs;
  RxBool showSendButton = false.obs;
  RxBool isFileSending = false.obs;
  RxBool atMaxScroll = true.obs;

  RxBool isRecording = false.obs;

  RxBool conversationInfoLoading = false.obs;

  RxBool isForwarding = false.obs;

  StreamSubscription? robinStream;

  OverlayEntry? chatOptionsEntry;
  RxBool chatOptionsOpened = false.obs;

  RxList selectedMessageIds = [].obs;

  Rx<RobinConversation> currentConversation = RobinConversation.empty().obs;

  RxMap currentConversationInfo = {}.obs;

  RxString selectedConversation = ''.obs;

  String allUsersSearchControllerPrevious = '';

  RobinMessage? replyMessage;

  Map userColors = {};

  Map messageDrafts = {};

  RxMap conversationMessages = {}.obs;

  RxList file = [].obs;

  RxMap groupIcon = {}.obs;

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
  FocusNode messageFocus = FocusNode();

  TextEditingController groupChatNameController = TextEditingController();

  AppLifecycleState state = AppLifecycleState.resumed;

  void initializeController(String _apiKey, RobinCurrentUser _currentUser,
      Function _getUsers, RobinKeys _keys) {
    robinCore = RobinCore();
    apiKey = _apiKey;
    currentUser = _currentUser;
    getUsers = _getUsers;
    keys = _keys;
    robinConnect();
    robinInitialized = true;
    getConversations(refresh: false);
    homeSearchController.addListener(() {
      renderHomeConversations();
    });
    archiveSearchController.addListener(() {
      renderArchivedConversations();
    });
    allUsersSearchController.addListener(() {
      if (allUsersSearchControllerPrevious != allUsersSearchController.text) {
        renderAllUsers();
        allUsersSearchControllerPrevious = allUsersSearchController.text;
      }
    });
    messageController.addListener(() {
      showSendButton.value = messageController.text.isNotEmpty;
    });
    messageFocus.addListener(() {
      if (messageFocus.hasPrimaryFocus) {
        Future.delayed(const Duration(milliseconds: 700), () {
          scrollToEnd();
        });
      }
    });
    forwardController.addListener(() {
      renderForwardConversations();
    });
    groupChatNameController.addListener(() {
      groupChatNameEmpty.value = groupChatNameController.text.isEmpty;
    });
    getConversations(refresh: true);
  }

  void appResume() {
    if (robinConnection!.closeCode != null) {
      robinConnect();
      getConversations(refresh: false);
      if (currentConversation.value.id != null) {
        getMessages(refresh: true);
      }
    }
  }

  Future robinConnect() async {
    robinConnection = robinCore!.connect(apiKey, currentUser!.robinToken);
    Future.delayed(const Duration(milliseconds: 750), () {
      robinCore!.subscribe();
    });
    Future.delayed(const Duration(milliseconds: 750), () {
      connectionStartListen();
    });
  }

  connectionStartListen() async {
    await robinStream?.cancel();
    robinStream = robinConnection?.stream.listen(
      (data) {
        data = json.decode(data);
        print(data);
        if (data['is_event'] == null || data['is_event'] == false) {
          handleNewMessage(data);
        } else {
          switch (data['name']) {
            case 'message.forward':
              handleMessageForward(data['value']);
              break;
            case 'delete.message':
              handleDeleteMessagesFromEvent(data['value']);
              break;
            case 'new.group.moderator':
              handleNewGroupModerator(data['value']);
              break;
            case 'remove.group.participant':
              handleRemoveGroupParticipant(data['value']);
              break;
            case 'message.reaction':
              if (conversationMessages[data['value']['message_id']] != null) {
                RobinMessage robinMessage =
                    conversationMessages[data['value']['message_id']];
                RobinMessageReaction reaction =
                    RobinMessageReaction.fromJson(data['value']);
                bool reactionExists = false;
                for (RobinMessageReaction robinReaction
                    in robinMessage.allReactions.values.toList()) {
                  if (robinReaction.id == reaction.id) {
                    reactionExists = true;
                    break;
                  }
                }
                if (!reactionExists) {
                  if (robinMessage.allReactions[reaction.type] != null) {
                    reaction.number =
                        robinMessage.allReactions[reaction.type]!.number += 1;
                    robinMessage.allReactions[reaction.type] = reaction;
                  } else {
                    robinMessage.allReactions[reaction.type] = reaction;
                  }
                  if (reaction.userToken == currentUser?.robinToken) {
                    robinMessage.myReactions[reaction.type] = reaction;
                  }
                  conversationMessages[data['value']['message_id']] =
                      robinMessage;
                }
              }
              break;
            case 'message.remove.reaction':
              if (conversationMessages[data['value']['message_id']] != null) {
                RobinMessage robinMessage =
                    conversationMessages[data['value']['message_id']];
                if (robinMessage
                        .allReactions[data['value']['reaction']['reaction']] !=
                    null) {
                  int num = robinMessage
                      .allReactions[data['value']['reaction']['reaction']]!
                      .number;
                  if (num > 1) {
                    robinMessage
                        .allReactions[data['value']['reaction']['reaction']]!
                        .number = num - 1;
                  } else {
                    robinMessage.allReactions
                        .remove([data['value']['reaction']['reaction']]);
                  }
                  conversationMessages[data['value']['message_id']] =
                      robinMessage;
                }
                for (RobinMessageReaction reaction
                    in robinMessage.myReactions.values.toList()) {
                  if (reaction.id == data['value']['_id']) {
                    robinMessage.myReactions.remove(reaction.type);
                    conversationMessages[data['value']['message_id']] =
                        robinMessage;
                    break;
                  }
                }
              }
              break;
            case 'new.conversation':
              handleNewConversation(data['value']);
              break;
            case 'group.icon.update':
              handleGroupIconUpdate(data['value']);
              break;
            case 'read.reciept':
              if (currentConversation.value.id != null &&
                  currentConversation.value.id ==
                      data['value']['conversation_id']) {
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
      },
      onError: (error) {
        // print(error.toString());
        // Future.delayed(const Duration(seconds: 1), () {
        //   print('on error');
        //   robinConnect();
        // });
      },
    );
  }

  handleNewMessage(Map data, {bool? isDelivered}) {
    bool delivered = isDelivered ?? true;
    RobinMessage robinMessage = RobinMessage.fromJson(data, delivered);
    if (allConversations[robinMessage.conversationId] != null) {
      if (delivered) {
        updateLocalConversationMessages(robinMessage.conversationId, data);
      }
      if (!robinMessage.sentByMe && state == AppLifecycleState.resumed) {
        FlutterRingtonePlayer.playNotification();
      }
      allConversations[robinMessage.conversationId]?.lastMessage =
          RobinLastMessage.fromRobinMessage(robinMessage);
      allConversations[robinMessage.conversationId]?.updatedAt = DateTime.now();
      if (robinMessage.conversationId != currentConversation.value.id &&
          !robinMessage.sentByMe) {
        int unreadMessages =
            allConversations[robinMessage.conversationId]?.unreadMessages ?? 0;
        unreadMessages += 1;
        allConversations[robinMessage.conversationId]?.unreadMessages =
            unreadMessages;
      }
      allConversations[robinMessage.conversationId] =
          allConversations[robinMessage.conversationId]!;
      var sortedEntries = sortConversations();
      allConversations =
          Map<String, RobinConversation>.fromEntries(sortedEntries);
      updateLocalConversations();
      if (allConversations[robinMessage.conversationId]!.archived!) {
        renderArchivedConversations();
      } else {
        renderHomeConversations();
      }
    }
    if (robinMessage.conversationId == currentConversation.value.id) {
      if (delivered &&
          conversationMessages.keys.contains(robinMessage.localId)) {
        conversationMessages[robinMessage.localId] = robinMessage;
        conversationMessages.updateKey(
          currentKey: robinMessage.localId,
          newKey: robinMessage.id,
        );
      } else {
        conversationMessages.value = {
          robinMessage.id: robinMessage,
          ...conversationMessages
        };
      }
      if (!robinMessage.sentByMe) {
        sendReadReceipts([robinMessage.id]);
      }
      if (atMaxScroll.value) {
        Future.delayed(const Duration(milliseconds: 17), () {
          scrollToEnd();
        });
      }
    }
  }

  handleRemoveGroupParticipant(Map value) {
    if (allConversations[value['conversation_id']] != null) {
      RobinConversation conversation =
          allConversations[value['conversation_id']]!;
      List participants = conversation.participants!;
      int index = 0;
      bool found = false;
      for (int i = 0; i < participants.length; i++) {
        if (participants[i]['user_token'] ==
            value['participant']['user_token']) {
          index = i;
          found = true;
          break;
        }
      }
      if (found) {
        participants.removeAt(index);
        conversation.participants = participants;
        allConversations[conversation.id!] = conversation;
        updateLocalConversations();
        if (conversation.archived!) {
          renderArchivedConversations();
        } else {
          renderHomeConversations();
        }
        if (currentConversation.value.id! == value['conversation_id']) {
          currentConversation.value = conversation;
          rc.chatViewLoading.value = true;
          rc.chatViewLoading.value = false;
        }
      }
    }
  }

  handleNewGroupModerator(Map value) {
    if (allConversations[value['conversation_id']] != null) {
      RobinConversation conversation =
          allConversations[value['conversation_id']]!;
      List participants = conversation.participants!;
      int index = 0;
      for (int i = 0; i < participants.length; i++) {
        if (participants[i]['user_token'] ==
            value['participant']['user_token']) {
          index = i;
          break;
        }
      }
      participants[index]['is_moderator'] = true;
      conversation.participants = participants;
      allConversations[conversation.id!] = conversation;
      updateLocalConversations();
      if (conversation.archived!) {
        renderArchivedConversations();
      } else {
        renderHomeConversations();
      }
      if (currentConversation.value.id! == value['conversation_id']) {
        currentConversation.value = conversation;
        rc.chatViewLoading.value = true;
        rc.chatViewLoading.value = false;
      }
    }
  }

  handleGroupIconUpdate(Map conversation) {
    RobinConversation robinConversation =
        RobinConversation.fromJson(conversation);
    if (robinConversation.isGroup!) {
      for (Map user in robinConversation.participants!) {
        if (user['user_token'] == currentUser?.robinToken) {
          allConversations.remove(robinConversation.id!);
          allConversations = {
            robinConversation.id!: robinConversation,
            ...allConversations,
          };
          updateLocalConversations();
          if (robinConversation.archived!) {
            renderArchivedConversations();
          } else {
            renderHomeConversations();
          }
          break;
        }
      }
    } else if (currentUser?.robinToken == robinConversation.token) {
      allConversations.remove(robinConversation.id!);
      allConversations = {
        robinConversation.id!: robinConversation,
        ...allConversations,
      };
      updateLocalConversations();
      if (robinConversation.archived!) {
        renderArchivedConversations();
      } else {
        renderHomeConversations();
      }
    }
  }

  handleNewConversation(Map conversation) {
    RobinConversation robinConversation =
        RobinConversation.fromJson(conversation);
    if (robinConversation.isGroup!) {
      for (Map user in robinConversation.participants!) {
        if (user['user_token'] == currentUser?.robinToken) {
          allConversations = {
            robinConversation.id!: robinConversation,
            ...allConversations,
          };
          updateLocalConversations();
          if (robinConversation.archived!) {
            renderArchivedConversations();
          } else {
            renderHomeConversations();
          }
          break;
        }
      }
    } else if (currentUser?.robinToken == robinConversation.token ||
        currentUser?.robinToken == robinConversation.altToken) {
      allConversations = {
        robinConversation.id!: robinConversation,
        ...allConversations,
      };
      updateLocalConversations();
      if (robinConversation.archived!) {
        renderArchivedConversations();
      } else {
        renderHomeConversations();
      }
    }
  }

  handleMessageForward(List messages) {
    for (int index = 0; index < messages.length; index++) {
      Map message = messages[index];
      handleNewMessage(message);
    }
  }

  scrollToEnd() {
    messagesScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }

  void getConversations({bool? refresh}) async {
    try {
      if (allConversations.isEmpty) isConversationsLoading.value = true;
      var conversations = await robinCore!
          .getDetailsFromUserToken(currentUser!.robinToken, refresh: refresh);
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
      allConversations[robinConversation.id!] = robinConversation;
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

  sortConversations() {
    return allConversations.entries.toList()
      ..sort((e1, e2) {
        var diff = e2.value.updatedAt!.compareTo(e1.value.updatedAt!);
        if (diff == 0) diff = e2.key.compareTo(e1.key);
        return diff;
      });
  }

  void archiveConversation(String conversationId, String key) {
    robinCore!.archiveConversation(conversationId, currentUser!.robinToken);
    allConversations[key]!.archived = true;
    updateLocalConversations();
    renderHomeConversations();
    renderArchivedConversations();
  }

  void unarchiveConversation(String conversationId, String key) {
    robinCore!.unarchiveConversation(conversationId, currentUser!.robinToken);
    allConversations[key]!.archived = false;
    updateLocalConversations();
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

  void getAddGroupUsers(List<String> existingParticipants) async {
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
        if (!existingParticipants.contains(robinToken)) {
          allRobinUsers.add(
            RobinUser(displayName: displayName, robinToken: robinToken),
          );
        }
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
        conversation.id!: conversation,
        ...allConversations,
      };
      updateLocalConversations();
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
        'meta_data': {'display_name': currentUser!.fullName}
      };
      var response = await robinCore!.createGroupChat(body);
      RobinConversation conversation = RobinConversation.fromJson(response);
      if (groupIcon['file'] == null) {
        isCreatingGroup.value = false;
        allConversations = {
          conversation.id!: conversation,
          ...allConversations,
        };
        updateLocalConversations();
        renderHomeConversations();
        renderArchivedConversations();
      }
      return conversation;
    } catch (e) {
      isCreatingGroup.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  Future<bool> addGroupParticipants() async {
    try {
      isCreatingGroup.value = true;
      Map<String, dynamic> body = {
        'participants': createGroupParticipants.values.toList(),
      };
      var response = await robinCore!
          .addGroupParticipants(body, currentConversation.value.id!);
      currentConversation.value = RobinConversation.fromJson(response);
      allConversations[currentConversation.value.id!] =
          currentConversation.value;
      updateLocalConversations();
      if (currentConversation.value.archived!) {
        renderArchivedConversations();
      } else {
        renderHomeConversations();
      }
      return true;
    } catch (e) {
      isCreatingGroup.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void assignGroupModerator(String userToken) async {
    try {
      conversationInfoLoading.value = true;
      Map<String, String> body = {
        'user_token': userToken,
      };
      var response = await robinCore!
          .assignGroupModerator(body, currentConversation.value.id!);
      currentConversation.value = RobinConversation.fromJson(response);
      allConversations[currentConversation.value.id!] =
          currentConversation.value;
      if (currentConversation.value.archived!) {
        renderArchivedConversations();
      } else {
        renderHomeConversations();
      }
      conversationInfoLoading.value = false;
    } catch (e) {
      conversationInfoLoading.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void removeGroupParticipant(String userToken) async {
    try {
      conversationInfoLoading.value = true;
      Map<String, String> body = {
        'user_token': userToken,
      };
      var response = await robinCore!
          .removeGroupParticipant(body, currentConversation.value.id!);
      currentConversation.value = RobinConversation.fromJson(response);
      allConversations[currentConversation.value.id!] =
          currentConversation.value;
      if (currentConversation.value.archived!) {
        renderArchivedConversations();
      } else {
        renderHomeConversations();
      }
      conversationInfoLoading.value = false;
    } catch (e) {
      conversationInfoLoading.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  uploadGroupIcon(String conversationId) async {
    try {
      if (groupIcon['file'] != null) {
        isCreatingGroup.value = true;
        List<http.MultipartFile> files = [
          await http.MultipartFile.fromPath(
            'file',
            groupIcon['file'].path,
          ),
        ];
        var response = await robinCore!.uploadGroupIcon(conversationId, files);
        RobinConversation conversation = RobinConversation.fromJson(response);
        groupIcon.value = {};
        isCreatingGroup.value = false;
        allConversations = {
          conversation.id!: conversation,
          ...allConversations,
        };
        updateLocalConversations();
        renderHomeConversations();
        renderArchivedConversations();
        return conversation;
      }
    } catch (e) {
      isCreatingGroup.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void initChatView(RobinConversation conversation, bool newUser) {
    resetChatView();
    userColors = {};
    messageController.clear();
    currentConversation.value = conversation;
    String pastMessage = messageDrafts[currentConversation.value.id!] ?? '';
    if (pastMessage.isNotEmpty) {
      messageController.text = pastMessage;
    }
    messageDrafts.remove(currentConversation.value.id!);
    if (currentConversation.value.isGroup!) {
      generateUserColors();
    }
    if (newUser != true) getMessages(refresh: false);
    getMessages(refresh: true);
  }

  void resetChatView() {
    selectMessageView.value = false;
    selectedMessageIds.value = [].obs;
    forwardConversations.value = [].obs;
    forwardConversationIds.value = [].obs;
    isForwarding.value = false;
    file.value = [];
    replyView.value = false;
    replyMessage = null;
    chatViewLoading.value = false;
  }

  void handleMessageDraft(String conversationId) {
    if (rc.messageController.text.isNotEmpty) {
      messageDrafts[conversationId] = rc.messageController.text;
    } else {
      messageDrafts[conversationId] = "";
    }
  }

  void generateUserColors() {
    List<Color> colors = groupUserColors.toList();
    for (Map user in currentConversation.value.participants!) {
      if (colors.length < 2) {
        colors = groupUserColors.toList();
      }
      userColors[user['user_token']] = (colors.toList()..shuffle()).first;
      colors.remove(userColors[user['user_token']]);
    }
    userColors[currentUser!.robinToken] = green;
  }

  Future<bool> leaveGroup(String groupId, {bool? showLoader}) async {
    try {
      chatViewLoading.value = showLoader ?? true;
      Map<String, String> body = {
        'user_token': currentUser!.robinToken,
      };
      await robinCore!.removeGroupParticipant(body, groupId);
      chatViewLoading.value = false;
      return true;
    } catch (e) {
      chatViewLoading.value = false;
      if (showLoader ?? true) {
        showErrorMessage(e.toString());
      }
      rethrow;
    }
  }

  Future<bool> deleteConversation(
      {bool? showLoader, String? conversationId}) async {
    try {
      chatViewLoading.value = showLoader ?? true;
      await robinCore!.deleteConversation(
          conversationId ?? currentConversation.value.id!,
          currentUser!.robinToken);
      chatViewLoading.value = false;
      return true;
    } catch (e) {
      chatViewLoading.value = false;
      if (showLoader ?? true) {
        showErrorMessage(e.toString());
      }
      rethrow;
    }
  }

  void getMessages({bool? refresh}) async {
    try {
      if (conversationMessages.isEmpty) {
        chatViewLoading.value = true;
      }
      var response = await robinCore!.getConversationMessages(
          currentConversation.value.id!, currentUser!.robinToken,
          refresh: refresh);
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

    List<RobinMessage> imageGroup = [];

    for (Map message in messages) {
      RobinMessage robinMessage = RobinMessage.fromJson(message, true);
      if (!robinMessage.isRead && !robinMessage.sentByMe) {
        unreadMessages.add(robinMessage.id);
      }

      allMessages = {robinMessage.id: robinMessage, ...allMessages};

      // if (robinMessage.isAttachment &&
      //     fileType(
      //           path: robinMessage.link,
      //         ) ==
      //         'image' &&
      //     robinMessage.text.isEmpty) {
      //   if (imageGroup.isNotEmpty) {
      //     RobinMessage previousMessage = imageGroup.last;
      //     if (similarImageCheck(previousMessage, robinMessage)) {
      //       imageGroup.add(robinMessage);
      //       if(imageGroup.length < 4){
      //         allMessages = {robinMessage.id: robinMessage, ...allMessages};
      //       }
      //       if(imageGroup.length == 4){
      //         for(RobinMessage message in imageGroup){
      //           allMessages.remove(message.id);
      //         }
      //       }
      //     } else {
      //       RobinMessage groupRobinMessage = RobinMessage.fromGroup(imageGroup);
      //       allMessages = {groupRobinMessage.id: groupRobinMessage, ...allMessages};
      //       imageGroup = [];
      //       imageGroup.add(robinMessage);
      //       allMessages = {robinMessage.id: robinMessage, ...allMessages};
      //     }
      //   }
      //   else {
      //     imageGroup.add(robinMessage);
      //     allMessages = {robinMessage.id: robinMessage, ...allMessages};
      //   }
      // } else {
      //   if (imageGroup.isNotEmpty) {
      //     RobinMessage groupRobinMessage = RobinMessage.fromGroup(imageGroup);
      //     imageGroup = [];
      //     allMessages = {groupRobinMessage.id: groupRobinMessage, ...allMessages};
      //     allMessages = {robinMessage.id: robinMessage, ...allMessages};
      //   } else {
      //     allMessages = {robinMessage.id: robinMessage, ...allMessages};
      //   }
      // }


    }
    if(imageGroup.length >= 4){
      RobinMessage groupRobinMessage = RobinMessage.fromGroup(imageGroup);
      imageGroup = [];
      allMessages = {groupRobinMessage.id: groupRobinMessage, ...allMessages};
    }
    if (unreadMessages.isNotEmpty) {
      sendReadReceipts(unreadMessages);
    }
    return allMessages;
  }

  void sendTextMessage() {
    try {
      if (messageController.text.isNotEmpty) {
        Map<String, String> message = {
          'msg': messageController.text.trim(),
          'timestamp': formatISOTime(DateTime.now()),
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
          'local_id': uuid.v4()
        };
        Map localMessage = localRobinMessageJson(
          message,
          currentConversation.value.id!,
          currentUser!.robinToken,
          currentUser!.fullName,
        );
        handleNewMessage(localMessage, isDelivered: false);
        robinCore!.sendTextMessage(
          message,
          currentConversation.value.id!,
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
          'msg': messageController.text.trim(),
          'timestamp': formatISOTime(DateTime.now()),
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
          'local_id': uuid.v4()
        };
        Map localMessage = localRobinMessageJson(
          message,
          currentConversation.value.id!,
          currentUser!.robinToken,
          currentUser!.fullName,
          replyTo: replyMessage!.id,
        );
        handleNewMessage(localMessage, isDelivered: false);
        robinCore!.replyToMessage(
          message,
          currentConversation.value.id!,
          currentUser!.robinToken,
          currentUser!.fullName,
          replyMessage!.id,
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

  Future sendAttachment({String? path, List<String>? captions}) async {
    try {
      if (path != null) {
        isFileSending.value = true;
        Map<String, String> body = {
          'conversation_id': currentConversation.value.id!,
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
          'msg': messageController.text.trim(),
          'timestamp': formatISOTime(DateTime.now()),
          'file_path': path,
          'local_id': uuid.v4(),
        };
        Map localMessage = localRobinMessageJson(
          body,
          currentConversation.value.id!,
          currentUser!.robinToken,
          currentUser!.fullName,
          isAttachment: true,
          filePath: path,
        );
        handleNewMessage(localMessage, isDelivered: false);
        List<http.MultipartFile> files = [
          await http.MultipartFile.fromPath(
            'file',
            path,
          ),
        ];
        robinCore!.sendAttachment(body, files);
        messageController.clear();
        file.value = [];
        isFileSending.value = false;
      } else if (file.isNotEmpty) {
        isFileSending.value = true;
        for (int index = 0; index < file.length; index++) {
          var currentFile = file[index];
          Map<String, String> body = {
            'conversation_id': currentConversation.value.id!,
            'sender_token': currentUser!.robinToken,
            'sender_name': currentUser!.fullName,
            'msg': captions != null && index < captions.length
                ? captions[index]
                : messageController.text.trim(),
            'timestamp': formatISOTime(DateTime.now()),
            'file_path': currentFile.path,
            'local_id': uuid.v4(),
          };
          Map localMessage = localRobinMessageJson(
            body,
            currentConversation.value.id!,
            currentUser!.robinToken,
            currentUser!.fullName,
            isAttachment: true,
            filePath: currentFile.path,
          );
          handleNewMessage(localMessage, isDelivered: false);
          List<http.MultipartFile> files = [
            await http.MultipartFile.fromPath(
              'file',
              currentFile.path,
            ),
          ];
          robinCore!.sendAttachment(body, files);
        }
        messageController.clear();
        file.value = [];
        isFileSending.value = false;
      }
    } catch (e) {
      print(e);
      isFileSending.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  Future sendReplyAsAttachment({String? path, List<String>? captions}) async {
    try {
      if (path != null) {
        isFileSending.value = true;
        Map<String, String> body = {
          'conversation_id': currentConversation.value.id!,
          'message_id': replyMessage!.id,
          'sender_token': currentUser!.robinToken,
          'sender_name': currentUser!.fullName,
          'msg': messageController.text.trim(),
          'timestamp': formatISOTime(DateTime.now()),
          'file_path': path,
          'local_id': uuid.v4()
        };
        Map localMessage = localRobinMessageJson(
          body,
          currentConversation.value.id!,
          currentUser!.robinToken,
          currentUser!.fullName,
          replyTo: replyMessage!.id,
          isAttachment: true,
          filePath: path,
        );
        handleNewMessage(localMessage, isDelivered: false);
        List<http.MultipartFile> files = [
          await http.MultipartFile.fromPath(
            'file',
            path,
          ),
        ];
        robinCore!.replyWithAttachment(body, files);
        messageController.clear();
        file.value = [];
        isFileSending.value = false;
        replyMessage = null;
        replyView.value = false;
      } else if (file.isNotEmpty) {
        isFileSending.value = true;
        for (int index = 0; index < file.length; index++) {
          var currentFile = file[index];
          Map<String, String> body = {
            'conversation_id': currentConversation.value.id!,
            'message_id': replyMessage!.id,
            'sender_token': currentUser!.robinToken,
            'sender_name': currentUser!.fullName,
            'msg': captions != null && index < captions.length
                ? captions[index]
                : messageController.text.trim(),
            'timestamp': formatISOTime(DateTime.now()),
            'file_path': currentFile.path,
            'local_id': uuid.v4()
          };
          Map localMessage = localRobinMessageJson(
            body,
            currentConversation.value.id!,
            currentUser!.robinToken,
            currentUser!.fullName,
            replyTo: replyMessage!.id,
            isAttachment: true,
            filePath: currentFile.path,
          );
          handleNewMessage(localMessage, isDelivered: false);
          List<http.MultipartFile> files = [
            await http.MultipartFile.fromPath(
              'file',
              currentFile.path,
            ),
          ];
          robinCore!.replyWithAttachment(body, files);
        }
        messageController.clear();
        file.value = [];
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
        'sender_name': currentUser!.fullName,
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
      'conversation_id': currentConversation.value.id!,
      'message_ids': messageIds,
      'user_token': currentUser!.robinToken,
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

  void handleDeleteMessagesFromEvent(List deleteInfo) {
    bool didDelete = false;
    for (Map info in deleteInfo) {
      if (info['complete_delete'] ||
          info['delete_for'] == currentUser!.robinToken) {
        didDelete = true;
        conversationMessages.remove(info['id']);
      }
    }
    if (didDelete) {
      String conversationId = currentConversation.value.id ?? '';
      updateLocalConversationMessages(conversationId, {});
    }
  }

  void sendReaction(String reaction, String messageId) async {
    Map<String, dynamic> body = {
      'user_token': currentUser!.robinToken,
      'reaction': reaction,
      'conversation_id': currentConversation.value.id,
      'timestamp': getTimestamp(),
    };
    conversationMessages[messageId] = RobinMessage.fromJson(
      await robinCore!.sendReaction(body, messageId),
      true,
    );
  }

  void removeReaction(String messageId, String reactionId) async {
    conversationMessages[messageId] = RobinMessage.fromJson(
      await robinCore!.removeReaction(messageId, reactionId),
      true,
    );
  }

  void getConversationInfo() async {
    try {
      conversationInfoLoading.value = true;
      currentConversationInfo.value =
          await robinCore!.getConversationInfo(currentConversation.value.id!);
      List docs = [];
      List photos = [];
      if (currentConversationInfo['documents'] != null) {
        for (Map file in currentConversationInfo['documents']) {
          if (fileType(path: file['content']['attachment']) == 'image') {
            photos.add(file);
          } else {
            docs.add(file);
          }
        }
      }
      currentConversationInfo['documents'] = docs;
      currentConversationInfo['photos'] = photos;
      conversationInfoLoading.value = false;
    } catch (e) {
      conversationInfoLoading.value = false;
      showErrorMessage(e.toString());
      rethrow;
    }
  }

  void starMessage(String messageId) async {
    Map<String, dynamic> body = {
      'conversation_id': currentUser!.robinToken,
    };
    robinCore!.starMessage(body, messageId);
  }
}
