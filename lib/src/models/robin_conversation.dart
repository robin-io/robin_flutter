import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_last_message.dart';
import 'package:get/get.dart';

class RobinConversation {
  String? id;
  bool? isGroup;
  String? name;
  String? token;
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
        name = json['receiver_name'];
        token = json['receiver_token'];
      } else {
        name = json['sender_name'];
        token = json['sender_token'];
      }
    }
    lastMessage = RobinLastMessage.fromJson(json['last_message']);
    unreadMessages = getUnreadCount(json['unread_messages'] ?? {}, '${rc.currentUser?.robinToken}');
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

  int getUnreadCount(Map value, String userToken){
    int unread = 0;
    try{
      unread = value[userToken]['unread_count'];
      return unread;
    }catch(e){
      return unread;
    }
  }
}
