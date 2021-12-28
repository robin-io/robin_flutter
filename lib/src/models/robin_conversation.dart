import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_last_message.dart';
import 'package:get/get.dart';

class RobinConversation {
  late final String id;
  late final bool isGroup;
  late final String name;
  late final RobinLastMessage lastMessage;
  late final List participants;
  late final Map unreadMessages;
  late final bool archived;
  late final List deletedFor;
  late final DateTime updatedAt;

  final RobinController rc = Get.find();

  RobinConversation.fromJson(Map json) {
    id = json['_id'];
    isGroup = json['is_group'];
    if (isGroup) {
      name = json['name'];
    } else {
      if (rc.currentUser?.robinToken == json['sender_token']) {
        name = json['receiver_name'];
      } else {
        name = json['sender_name'];
      }
    }
    lastMessage = RobinLastMessage.fromJson(json['last_message']);
    participants = json['participants'] ?? [];
    unreadMessages = {};
    archived = json['archived_for'].contains(rc.currentUser?.robinToken);
    deletedFor = [];
    updatedAt = DateTime.parse(json['updated_at']);
  }
}
