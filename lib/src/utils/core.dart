import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:robin_flutter/src/networking/data_source.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RobinCore {
  static final DataSource api = DataSource();

  final RobinController rc = Get.find();

  WebSocketChannel connect(String? apiKey, String? userToken) {
    String url = '$wsUrl/$apiKey/$userToken';
    return WebSocketChannel.connect(
      Uri.parse(url),
    );
  }

  void subscribe() {
    Map sub = {
      'type': 0,
      'channel': robinChannel,
      'content': {},
      'conversation_id': "",
    };
    rc.robinConnection!.sink.add(json.encode(sub));
  }

  void replyToMessage(
      Map message, String conversationId, String replyTo, String senderToken) {
    Map msg = {
      'type': 1,
      'channel': robinChannel,
      'content': message,
      'sender_token': senderToken,
      'conversation_id': conversationId,
      'reply_to': replyTo,
      'is_reply': true,
    };
    rc.robinConnection!.sink.add(json.encode(msg));
  }

  void sendMessageToConversation(
      String conversationId, Map message, String senderToken) {
    Map msg = {
      'type': 1,
      'channel': robinChannel,
      'content': message,
      'sender_token': senderToken,
      'conversation_id': conversationId,
    };
    rc.robinConnection!.sink.add(json.encode(msg));
  }

  void createSupportTicket(
      String supportName, String senderToken, String senderName, Map message) {
    Map msg = {
      'type': 1,
      'channel': robinChannel,
      'content': message,
      'support_name': supportName,
      'sender_name': senderName,
      'sender_token': senderToken
    };
    rc.robinConnection!.sink.add(json.encode(msg));
  }

  static Future<String> createUserToken(
      String apiKey, Map<String, dynamic> body) async {
    try {
      Map<String, String> headers = {"x-api-key": apiKey};
      return await api.createUserToken(body, headers);
    } catch (e) {
      throw e.toString();
    }
  }

  getDetailsFromUserToken(String userToken) async {
    try {
      return await api.getDetailsFromUserToken(userToken);
    } catch (e) {
      throw e.toString();
    }
  }

  createConversation(Map<String, String> body) async {
    try {
      return await api.createConversation(body);
    } catch (e) {
      throw e.toString();
    }
  }

  getConversationMessages(String id, String userToken) async {
    try {
      return await api.getConversationMessages(id, userToken);
    } catch (e) {
      throw e.toString();
    }
  }

  createGroupChat(Map<String, dynamic> body) async {
    try {
      return await api.createGroupChat(body);
    } catch (e) {
      throw e.toString();
    }
  }

  assignGroupModerator(Map<String, dynamic> body, String id) async {
    try {
      return await api.assignGroupModerator(body, id);
    } catch (e) {
      throw e.toString();
    }
  }

  addGroupParticipants(Map<String, dynamic> body, String id) async {
    try {
      return await api.addGroupParticipants(body, id);
    } catch (e) {
      throw e.toString();
    }
  }

  removeGroupParticipant(Map<String, dynamic> body, String id) async {
    try {
      return await api.removeGroupParticipant(body, id);
    } catch (e) {
      throw e.toString();
    }
  }

  archiveConversation(String conversationId, String userToken) async {
    try {
      return await api.archiveConversation(conversationId, userToken);
    } catch (e) {
      throw e.toString();
    }
  }

  unarchiveConversation(String conversationId, String userToken) async {
    try {
      return await api.unarchiveConversation(conversationId, userToken);
    } catch (e) {
      throw e.toString();
    }
  }

  forwardMessages(Map<String, dynamic> body) async {
    try {
      return await api.forwardMessages(body);
    } catch (e) {
      throw e.toString();
    }
  }

  deleteMessages(Map<String, dynamic> body) async {
    try {
      return await api.deleteMessages(body);
    } catch (e) {
      throw e.toString();
    }
  }

  sendAttachment(
      Map<String, dynamic> body, List<http.MultipartFile> files) async {
    try {
      return await api.sendAttachment(body, files);
    } catch (e) {
      throw e.toString();
    }
  }

  replyWithAttachment(
      Map<String, dynamic> body, List<http.MultipartFile> files) async {
    try {
      return await api.replyWithAttachment(body, files);
    } catch (e) {
      throw e.toString();
    }
  }

  sendReaction(Map<String, dynamic> body, String messageId) async {
    try {
      return await api.sendReaction(body, messageId);
    } catch (e) {
      throw e.toString();
    }
  }

  removeReaction(
      Map<String, dynamic> body, String messageId, String reactionId) async {
    try {
      return await api.removeReaction(body, messageId, reactionId);
    } catch (e) {
      throw e.toString();
    }
  }

  sendReadReceipts(Map<String, dynamic> body) async {
    try {
      return await api.sendReadReceipts(body);
    } catch (e) {
      throw e.toString();
    }
  }
}
