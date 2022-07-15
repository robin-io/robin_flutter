import 'package:get/get.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_message_reaction.dart';

class RobinMessage {
  late final String id;
  late final String text;
  late final bool isAttachment;
  late final bool isGroupOfAttachments;
  late final String link;
  late final String conversationId;
  late final bool sentByMe;
  late final String senderName;
  late final String senderToken;
  late final String? replyTo;
  late final String? localId;
  late bool? delivered;
  bool isRead = false;
  late bool justSent;
  late String filePath;
  late final bool isForwarded;
  late final Map<String, RobinMessageReaction> allReactions;
  late final Map<String, RobinMessageReaction> myReactions;
  late final bool deletedForMe;
  late final DateTime timestamp;

  List<String> groupIds = [];
  List<String> groupLinks = [];
  List<bool> groupJustSent = [];
  List<bool> groupIsReads = [];
  List<bool> groupDelivered = [];
  List<String> groupFilePaths = [];
  List<Map<String, RobinMessageReaction>> groupAllReactions = [];
  List<Map<String, RobinMessageReaction>> groupMyReactions = [];
  List<DateTime> groupTimeStamps = [];

  final RobinController rc = Get.find();

  RobinMessage.fromJson(Map json, bool isDelivered) {
    id = json['_id'];
    isAttachment = json['content']['is_attachment'] ?? false;
    isGroupOfAttachments = false;
    text = json['content']['msg'] ?? "";
    link = isAttachment ? json['content']['attachment'] : '';
    conversationId = json['conversation_id'];
    isForwarded = json['is_forwarded'] ?? false;
    senderToken =
        isForwarded ? json['content']['sender_token'] : json['sender_token'];
    sentByMe = rc.currentUser?.robinToken == senderToken;
    senderName = json['sender_name'] ?? "";
    replyTo = json['reply_to'];
    localId = json['content']['local_id'] ?? '';
    filePath = json['content']['file_path'] ?? '';
    justSent = rc.conversationMessages.keys.contains(localId);
    delivered = isDelivered;
    isRead = json['is_read'] ?? false;
    List<Map<String, RobinMessageReaction>> reactions =
        getReactions(json['reactions'] ?? []);
    allReactions = reactions[0];
    myReactions = reactions[1];
    List deletedFor = json['deleted_for'] ?? [];
    deletedForMe = deletedFor.contains(rc.currentUser?.robinToken);
    print(json['created_at']);
    timestamp = json['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(json['created_at']).toLocal();
  }

  RobinMessage.fromGroup(List<RobinMessage> group) {
    id = group[0].id;
    isAttachment = true;
    isGroupOfAttachments = true;
    text = "";
    link = group[0].link;
    conversationId = group[0].conversationId;
    isForwarded = false;
    senderToken = group[0].senderToken;
    sentByMe = group[0].sentByMe;
    senderName = group[0].senderName;
    replyTo = group[0].replyTo;
    filePath = '';
    justSent = group[0].justSent;
    delivered = true;
    isRead = group[0].isRead;
    allReactions = group[0].allReactions;
    myReactions = group[0].myReactions;
    deletedForMe = group[0].deletedForMe;
    timestamp = group[0].timestamp;

    for(RobinMessage message in group){
      groupIds.add(message.id);
      groupLinks.add(message.link);
      groupJustSent.add(message.justSent);
      groupIsReads.add(message.isRead);
      groupDelivered.add(message.delivered ?? true);
      groupFilePaths.add(message.filePath);
      groupAllReactions.add(message.allReactions);
      groupMyReactions.add(message.myReactions);
      groupTimeStamps.add(message.timestamp);
    }

  }
}
