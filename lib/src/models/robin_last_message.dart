import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/models/robin_message.dart';

class RobinLastMessage {
  late final String text;
  late final bool isAttachment;
  late final bool sentByMe;
  late final String senderName;

  final RobinController rc = Get.find();

  RobinLastMessage.fromJson(Map? json) {
    if (json == null) {
      text = '';
      isAttachment = false;
      sentByMe = true;
      senderName = '';
    } else {
      isAttachment = json['is_attachment'];
      text = isAttachment ? "Attachment" : json['msg'];
      if (rc.currentUser?.robinToken == json['sender_token']) {
        sentByMe = true;
        senderName = '';
      } else {
        sentByMe = false;
        senderName =
            json['sender_token'] == null ? "" : '${json['sender_token']}: ';
      }
    }
  }

  RobinLastMessage.fromRobinMessage(RobinMessage message) {
    isAttachment = message.isAttachment;
    text = message.isAttachment ? 'Attachment' : message.text;
    if (message.sentByMe) {
      sentByMe = true;
      senderName = '';
    } else {
      sentByMe = false;
      senderName = message.senderName;
    }
  }
}
