import 'package:robin_flutter/src/networking/error_handler.dart';
import 'package:robin_flutter/src/networking/network_util.dart';
import 'package:robin_flutter/src/networking/endpoints.dart';
import 'package:http/http.dart' as http;

class DataSource {
  /// Instantiating the class [ErrorHandler]
  var errorHandler = ErrorHandler();

  /// Instantiating the class [NetworkHelper]
  var netUtil = NetworkHelper();

  createUserToken(Map<String, dynamic> body, Map<String, String> header) async {
    return netUtil
        .post(createUserTokenUrl, body, headers: header)
        .then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data']['user_token'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  getDetailsFromUserToken(String userToken) async {
    return netUtil
        .get('$getDetailsFromUserTokenUrl/$userToken')
        .then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data']['conversations'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  createConversation(Map<String, dynamic> body) async {
    return netUtil.post(createConversationUrl, body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  getConversationMessages(String id, String userToken) async {
    return netUtil
        .get('$getConversationMessagesUrl/$id/$userToken')
        .then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  createGroupChat(Map<String, dynamic> body) async {
    return netUtil.post(createGroupChatUrl, body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  assignGroupModerator(Map<String, dynamic> body, String id) async {
    return netUtil.put('$assignGroupModeratorUrl/$id', body: body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  addGroupParticipants(Map<String, dynamic> body, String id) async {
    return netUtil.put('$addGroupParticipantsUrl/$id', body: body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  removeGroupParticipant(Map<String, dynamic> body, String id) async {
    return netUtil.put('$removeGroupParticipantUrl/id', body: body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  archiveConversation(String id, String userToken) async {
    return netUtil.put('$archiveConversationUrl/$id/$userToken').then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  unarchiveConversation(String id, String userToken) async {
    return netUtil.put('$unarchiveConversationUrl/$id/$userToken').then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  forwardMessages(Map<String, dynamic> body) async {
    return netUtil.post(forwardMessagesUrl, body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  deleteMessages(Map<String, dynamic> body) async {
    return netUtil.delete(deleteMessagesUrl, body: body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  sendAttachment(Map<String, dynamic> body, List<http.MultipartFile> files) async {
    return netUtil.postForm(sendAttachmentUrl, files, body: body,).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  replyWithAttachment(Map<String, dynamic> body, List<http.MultipartFile> files) async {
    return netUtil.postForm(replyWithAttachmentUrl, files, body:body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  sendReaction(Map<String, dynamic> body, String messageId) async {
    return netUtil.post('$sendReactionUrl/$messageId', body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  removeReaction(Map<String, dynamic> body, String messageId, String reactionId) async {
    return netUtil.delete('$removeReactionUrl/$reactionId/$messageId', body:body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  sendReadReceipts(Map<String, dynamic> body) async {
    return netUtil.post(sendReadReceiptsUrl, body).then((response) {
      if (response['error']) {
        throw response['message'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }
}