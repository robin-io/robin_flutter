import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:robin_flutter/src/networking/data_source.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RobinCore {
  static final DataSource api = DataSource();

  final RobinController robinController = Get.find();

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
    robinController.robinConnection.sink.add(json.encode(sub));
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
    robinController.robinConnection.sink.add(json.encode(msg));
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
    robinController.robinConnection.sink.add(json.encode(msg));
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
    robinController.robinConnection.sink.add(json.encode(msg));
  }

  static Future<String> createUserToken(
      String apiKey, Map<String, dynamic> body) async {
    try {
      Map<String, String> headers = {"x-api-key": apiKey};
      api.createUserToken(body, headers).then((String userToken) async {
        return userToken;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'User Token Could Not Be Created';
  }

  getDetailsFromUserToken(String userToken) async {
    try {
      api.getDetailsFromUserToken(userToken).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Could Not Get Messages';
  }

  createConversation(Map<String, String> body) async {
    try {
      api.createConversation(body).then((conversation) async {
        return conversation;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Conversation Could Not Be Created';
  }

  getConversationMessages(String id, String userToken) async {
    try {
      api.getConversationMessages(id, userToken).then((messages) async {
        return messages;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Could Not Get Messages';
  }

  createGroupChat(Map<String, dynamic> body) async {
    try {
      api.createGroupChat(body).then((conversation) async {
        return conversation;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Group Chat Could Not Be Created';
  }

  assignGroupModerator(Map<String, dynamic> body, String id) async {
    try {
      api.assignGroupModerator(body, id).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Could Not Assign Group Moderator';
  }

  addGroupParticipants(Map<String, dynamic> body, String id) async {
    try {
      api.addGroupParticipants(body, id).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Participant Could Not Be Added To Group';
  }

  removeGroupParticipant(Map<String, dynamic> body, String id) async {
    try {
      api.removeGroupParticipant(body, id).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Participant Could Not Be Removed From Group';
  }

  archiveConversation(String id, String userToken) async {
    try {
      api.archiveConversation(id, userToken).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Conversation Could Not Be Archived';
  }

  unarchiveConversation(String id, String userToken) async {
    try {
      api.unarchiveConversation(id, userToken).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Conversation Could Not Be Unarchived';
  }

  forwardMessages(Map<String, dynamic> body) async {
    try {
      api.forwardMessages(body).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Messages Could Not Be Forwarded';
  }

  deleteMessages(Map<String, dynamic> body) async {
    try {
      api.deleteMessages(body).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Conversation Could Not Be Created';
  }

  sendAttachment(
      Map<String, dynamic> body, List<http.MultipartFile> files) async {
    try {
      api.sendAttachment(body, files).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'File Could Not Be Sent';
  }

  replyWithAttachment(
      Map<String, dynamic> body, List<http.MultipartFile> files) async {
    try {
      api.replyWithAttachment(body, files).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'File Could Not Be Sent';
  }

  sendReaction(Map<String, dynamic> body, String messageId) async {
    try {
      api.sendReaction(body, messageId).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Reaction Could Not Be Sent';
  }

  removeReaction(
      Map<String, dynamic> body, String messageId, String reactionId) async {
    try {
      api.removeReaction(body, messageId, reactionId).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Reaction Could Not Be Removed';
  }

  sendReadReceipts(Map<String, dynamic> body) async {
    try {
      api.sendReadReceipts(body).then((response) async {
        return response;
      }).catchError((e) {
        throw e.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    throw 'Read Receipts Could Not Be Sent';
  }
}
