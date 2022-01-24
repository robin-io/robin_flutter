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
  RobinLastMessage? lastMessage;
  List? participants;
  Map? unreadMessages;
  bool? archived;
  List? deletedFor;
  DateTime? updatedAt;
  DateTime? createdAt;

  final RobinController rc = Get.find();

  RobinConversation.fromJson(Map json) {
    id = json['_id'];
    isGroup = json['is_group'];
    participants = json['participants'] ?? [];
    if (isGroup!) {
      print(json);
      name = json['name'];
      moderatorToken = json['moderator']['user_token'];
      moderatorName = json['moderator']['meta_data'] == null
          ? ''
          : json['moderator']['meta_data']['displayName'];
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
    unreadMessages = {};
    archived = json['archived_for'].contains(rc.currentUser?.robinToken);
    deletedFor = [];
    updatedAt = json['last_message'] == null
        ? DateTime.parse(json['updated_at'])
        : DateTime.parse(json['last_message']['timestamp']);
    createdAt = DateTime.parse(json['created_at']);
  }
}
