import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
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
        throw response['msg'];
      } else {
        return response['data']['user_token'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  getDetailsFromUserToken(String userToken, {bool? refresh}) async {
    String fileName = 'userDetails$userToken.json';
    var dir = await getTemporaryDirectory();
    File file = File(dir.path + '/$fileName');
    if (refresh == false && file.existsSync()) {
      final fileData = file.readAsStringSync();
      final response = jsonDecode(fileData);
      return response['data']['conversations'];
    }
    return netUtil
        .get('$getDetailsFromUserTokenUrl/$userToken')
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        file.writeAsStringSync(jsonEncode(response),
            flush: true, mode: FileMode.write);
        return response['data']['conversations'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  sendDeviceToken(String userToken, String deviceToken) async {
    return netUtil.post(
        '$sendDeviceTokenUrl/$userToken', {"device_token": deviceToken}).then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  createConversation(Map<String, dynamic> body) async {
    return netUtil.post(createConversationUrl, body).then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  getConversationMessages(String conversationId, String userToken,
      {bool? refresh}) async {
    String fileName = 'conversation$conversationId$userToken.json';
    var dir = await getTemporaryDirectory();
    File file = File(dir.path + '/$fileName');
    if (refresh == false && file.existsSync()) {
      final fileData = file.readAsStringSync();
      final response = jsonDecode(fileData);
      return response['data'];
    } else {
      return netUtil
          .get('$getConversationMessagesUrl/$conversationId/$userToken')
          .then((response) {
        if (response['error']) {
          throw response['msg'];
        } else {
          file.writeAsStringSync(jsonEncode(response),
              flush: true, mode: FileMode.write);
          return response['data'];
        }
      }).catchError((e) {
        errorHandler.handleError(e);
      });
    }
  }

  createGroupChat(Map body) async {
    return netUtil.post(createGroupChatUrl, body).then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  assignGroupModerator(Map<String, dynamic> body, String id) async {
    return netUtil
        .put('$assignGroupModeratorUrl/$id', body: body)
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  addGroupParticipants(Map<String, dynamic> body, String id) async {
    return netUtil
        .put('$addGroupParticipantsUrl/$id', body: body)
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  removeGroupParticipant(Map<String, dynamic> body, String groupId) async {
    return netUtil
        .put('$removeGroupParticipantUrl/$groupId', body: body)
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  deleteConversation(String conversationId, String userToken) async {
    return netUtil
        .delete(
      '$deleteConversationUrl/$conversationId/$userToken',
    )
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  getOnlineStatus(Map<String, dynamic> body) async{
    return netUtil
        .post(onlineStatusUrl, body)
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  archiveConversation(String conversationId, String userToken) async {
    return netUtil
        .put('$archiveConversationUrl/$conversationId/$userToken')
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  unarchiveConversation(String conversationId, String userToken) async {
    return netUtil
        .put('$unarchiveConversationUrl/$conversationId/$userToken')
        .then((response) {
      if (response['error']) {
        throw response['msg'];
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
        throw response['msg'];
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
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  sendAttachment(
      Map<String, dynamic> body, List<http.MultipartFile> files) async {
    return netUtil
        .postForm(
      sendAttachmentUrl,
      files,
      body: body,
    )
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  replyWithAttachment(
      Map<String, dynamic> body, List<http.MultipartFile> files) async {
    return netUtil
        .postForm(replyWithAttachmentUrl, files, body: body)
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  uploadGroupIcon(String conversationId, List<http.MultipartFile> files) async {
    return netUtil.postForm('$uploadGroupIconUrl/$conversationId', files,
        body: {"": ""}).then((response) {
      if (response['error']) {
        throw response['msg'];
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
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  removeReaction(String messageId, String reactionId) async {
    return netUtil
        .delete('$removeReactionUrl/$reactionId/$messageId')
        .then((response) {
      if (response['error']) {
        throw response['msg'];
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
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  getConversationInfo(String conversationId, String userToken) async {
    return netUtil
        .get('$getConversationInfoUrl/$conversationId/$userToken')
        .then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  starMessage(Map<String, dynamic> body, String messageId) async {
    return netUtil.post('$starMessage/$messageId', body).then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }

  getStarredMessages(String userToken) async {
    return netUtil.get('$starMessage/$userToken').then((response) {
      if (response['error']) {
        throw response['msg'];
      } else {
        return response['data'];
      }
    }).catchError((e) {
      errorHandler.handleError(e);
    });
  }
}
