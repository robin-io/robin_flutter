import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_last_message.dart';
import 'package:get/get.dart';

class RobinConversation {
  String? id;
  bool? isGroup;
  String? name;
  RobinLastMessage? lastMessage;
  List? participants;
  Map? unreadMessages;
  bool? archived;
  List? deletedFor;
  DateTime? updatedAt;
  int? index;

  final RobinController rc = Get.find();

  RobinConversation.fromJson(Map json) {
    id = json['_id'];
    isGroup = json['is_group'];
    if (isGroup!) {
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
