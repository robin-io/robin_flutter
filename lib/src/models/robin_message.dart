import 'package:get/get.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_message_reaction.dart';

class RobinMessage {
  late final String id;
  late final String text;
  late final bool isAttachment;
  late final String link;
  late final String conversationId;
  late final bool sentByMe;
  late final String senderName;
  late final String senderToken;
  late final String? replyTo;
  bool isRead = false;
  late final bool isForwarded;
  late final Map<String, RobinMessageReaction> reactions;
  late final bool deletedForMe;
  late final DateTime timestamp;

  final RobinController rc = Get.find();

  RobinMessage.fromJson(Map json) {
    id = json['_id'];
    isAttachment = json['content']['is_attachment'] ?? false;
    text = isAttachment ? "" : json['content']['msg'];
    link = isAttachment ? json['content']['attachment'] : '';
    conversationId = json['conversation_id'];
    isForwarded = json['is_forwarded'] ?? false;
    senderToken = isForwarded ? json['content']['sender_token'] : json['sender_token'];
    sentByMe = rc.currentUser?.robinToken == senderToken;
    senderName = json['sender_name'];
    replyTo = json['reply_to'];
    isRead = json['is_read'] ?? false;
    reactions =  convertToReactions(json['reactions'] ?? []);
    List deletedFor = json['deleted_for'] ?? [];
    deletedForMe = deletedFor.contains(rc.currentUser?.robinToken);
    timestamp = json['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['created_at']);
  }
}
