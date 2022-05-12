import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_last_message.dart';
import 'package:get/get.dart';

class RobinConversation {
  String? id;
  bool? isGroup;
  String? name;
  String? token;
  String? altToken;
  String? moderatorName;
  String? moderatorToken;
  String? conversationIcon;
  RobinLastMessage? lastMessage;
  List? participants;
  int? unreadMessages;
  bool? archived;
  List? deletedFor;
  DateTime? updatedAt;
  DateTime? createdAt;
  bool? sentByMe;

  RobinConversation.fromJson(Map json) {
    final RobinController rc = Get.find();
    id = json['_id'];
    isGroup = json['is_group'];
    participants = json['participants'] ?? [];
    if (isGroup!) {
      name = json['name'];
      moderatorToken = json['moderator']['user_token'];
      moderatorName = json['moderator']['meta_data'] == null
          ? ''
          : json['moderator']['meta_data']['display_name'];
      conversationIcon = json['group_icon'] ?? "";
    } else {
      if (rc.currentUser?.robinToken == json['sender_token']) {
        sentByMe = true;
        name = json['receiver_name'];
        token = json['receiver_token'];
        altToken = json['sender_token'];
      } else {
        sentByMe = false;
        name = json['sender_name'];
        token = json['sender_token'];
        altToken = json['receiver_token'];
      }
    }
    lastMessage = RobinLastMessage.fromJson(json['last_message']);
    unreadMessages = getUnreadCount(
        json['unread_messages'] ?? {}, '${rc.currentUser?.robinToken}');
    archived = json['archived_for'].contains(rc.currentUser?.robinToken);
    deletedFor = [];
    updatedAt = json['last_message'] == null
        ? DateTime.parse(json['updated_at'])
        : DateTime.parse(json['last_message']['timestamp']);
    createdAt = DateTime.parse(json['created_at']);
  }

  RobinConversation.empty() {
    id = null;
    isGroup = null;
    participants = null;
    name = null;
    moderatorToken = null;
    moderatorName = null;
    conversationIcon = null;
    name = null;
    token = null;
    lastMessage = null;
    unreadMessages = null;
    archived = null;
    deletedFor = null;
    updatedAt = null;
    createdAt = null;
  }

  Map toJson() {
    final RobinController rc = Get.find();
    Map conversationJson = {
      '_id': id,
      'is_group': isGroup,
      'participants': participants,
      'archived_for': archived! ? [rc.currentUser?.robinToken] : [],
      'updated_at': updatedAt.toString(),
      'created_at': createdAt.toString(),
      'last_message': lastMessage!.toJson(),
      'unread_messages': {
        rc.currentUser?.robinToken: {
          'unread_count': unreadMessages,
        },
      },
    };
    if (conversationJson['last_message'] != null) {
      conversationJson['last_message']['timestamp'] =
          conversationJson['updated_at'];
    }
    if (isGroup!) {
      conversationJson['name'] = name;
      conversationJson['moderator'] = {};
      conversationJson['moderator']['user_token'] = moderatorToken;
      conversationJson['moderator']['meta_data'] = {};
      conversationJson['moderator']['meta_data']['display_name'] =
          moderatorName;
      conversationJson['group_icon'] = conversationIcon;
    } else {
      if (sentByMe!) {
        conversationJson['sender_token'] = rc.currentUser?.robinToken;
        conversationJson['receiver_name'] = name;
        conversationJson['receiver_token'] = token;
      } else {
        conversationJson['sender_name'] = name;
        conversationJson['sender_token'] = token;
      }
    }
    return conversationJson;
  }

  int getUnreadCount(Map value, String userToken) {
    int unread = 0;
    try {
      unread = value[userToken]['unread_count'];
      return unread;
    } catch (e) {
      return unread;
    }
  }
}
