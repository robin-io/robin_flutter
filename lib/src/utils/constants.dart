import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RobinCore {
  static String _url = "api.robinapp.co";
  final String _baseUrl = "https://$_url/api/v1";
  final String _wss = 'wss://$_url/ws';
  final String _ws = 'ws://$_url/ws';
  late final String _secret;
  final bool _tls = true;

  final JsonDecoder _decoder = JsonDecoder();

  RobinCore(){
    _setRobinKey();
  }

  RobinCore.named(String apiKey){
    _secret = apiKey;
  }


  _setRobinKey() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _secret = prefs.getString('RobinApiKey') ?? "";
  }

  Future<String> createUserToken(Map data) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/chat/user_token'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode(data),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data']['user_token'];
      }
    } catch (e) {
      print(e.toString());
    }
    return '';
  }

  Future<Map> getUserToken(String userToken) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/chat/user_token/$userToken'),
        headers: {
          "x-api-key": _secret,
        },
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res);
      }
    } catch (e) {
      print(e.toString());
    }
    return {};
  }

  Future<String> syncUserToken(Map data) async {
    try {
      http.Response response = await http.put(
        Uri.parse('$_baseUrl/chat/user_token/${data['userToken']}'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode(data),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
    return '';
  }

  Future createConversation(Map data) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/conversation'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode(data),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future getConversationMessages(String id, String userToken) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/conversation/messages/$id/$userToken'),
        headers: {
          "x-api-key": _secret,
        },
      );
      final String res = response.body;
      print(res);
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future searchConversation(String id, String text) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/chat/search/message/$id'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode(text),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future deleteMessages(Map body) async {
    try {
      http.Response response = await http.delete(
        Uri.parse('$_baseUrl/chat/message'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode(body),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future createGroupConversation(
      String name, Map moderator, List<Map> participants) async {
    try {
      print(json.encode({
        'name': name,
        'moderator': moderator,
        'participants': participants
      }));
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/chat/conversation/group'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode({
          'name': name,
          'moderator': moderator,
          'participants': participants
        }),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future assignGroupModerator(String id, String userToken) async {
    try {
      http.Response response = await http.put(
        Uri.parse('$_baseUrl/chat/conversation/group/assign_moderator/$id'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode({'user_token': userToken}),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future addGroupParticipants(String id, List<String> participants) async {
    try {
      http.Response response = await http.put(
        Uri.parse('$_baseUrl/chat/conversation/group/add_participants/$id'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode({'participants': participants}),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future removeGroupParticipant(String id, String userToken) async {
    try {
      http.Response response = await http.put(
        Uri.parse('$_baseUrl/chat/conversation/group/remove_participant/$id'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode({'user_token': userToken}),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future archiveConversation(String id, String userToken) async {
    try {
      http.Response response = await http.put(
        Uri.parse('$_baseUrl/conversation/archive/$id/$userToken'),
        headers: {
          "x-api-key": _secret,
        },
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future unarchiveConversation(String id, String userToken) async {
    try {
      http.Response response = await http.put(
        Uri.parse('$_baseUrl/conversation/unarchive/$id/$userToken'),
        headers: {
          "x-api-key": _secret,
        },
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future forwardMessages(
      String userToken, List messageIds, List conversationIds) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/conversation/forward_messages'),
        headers: {
          "x-api-key": _secret,
        },
        body: json.encode({
          'user_token': userToken,
          'message_ids': messageIds,
          'conversation_ids': conversationIds,
        }),
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  connect(String userToken) {
    if (_secret.length > 0) {
      WebSocketChannel conn;
      String uri;
      if (_tls) {
        uri = _wss + '/$_secret/$userToken';
        conn = WebSocketChannel.connect(
          Uri.parse(uri),
        );
      } else {
        uri = _ws + '/$_secret/$userToken';
        conn = WebSocketChannel.connect(
          Uri.parse(uri),
        );
      }
      return conn;
    }
    return false;
  }

  void subscribe(WebSocketChannel conn, String channel) {
    Map sub = {
      'type': 0,
      'channel': channel,
      'content': {},
      'conversation_id': "",
    };
    print('subscribed');
    conn.sink.add(json.encode(sub));
  }

  void sendMessageToConversation(WebSocketChannel conn, String channel,
      String conversationId, Map message, String senderToken) {
    Map msg = {
      'type': 1,
      'channel': channel,
      'content': message,
      'sender_token': senderToken,
      'conversation_id': conversationId,
    };
    conn.sink.add(json.encode(msg));
  }

  void createSupportTicket(WebSocketChannel conn, String channel,
      String supportName, String senderToken, String senderName, Map message) {
    Map msg = {
      'type': 1,
      'channel': channel,
      'content': message,
      'support_name': supportName,
      'sender_name': senderName,
      'sender_token': senderToken
    };
    conn.sink.add(json.encode(msg));
  }

  Future getUnassignedUsers(String supportName) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$_baseUrl/chat/support/unassigned/$supportName'),
        headers: {
          "x-api-key": _secret,
        },
      );
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future sendMessageAttachment(String userToken, String senderName,
      String conversationId, String? filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/chat/message/send/attachment/'),
      );
      request.headers.addAll({
        "x-api-key": _secret,
      });
      request.fields.addAll({
        'sender_token': userToken,
        'sender_name': senderName,
        'conversation_id': conversationId,
      });
      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            filePath,
          ),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final dynamic res = json.decode(response.body);
      final int statusCode = response.statusCode;
      if (statusCode == 401) {
        throw ("Unauthorized");
      } else if (statusCode < 200 || statusCode > 400 || json == null) {
        throw ("${res["message"]}");
      }
      return res;
    } catch (e) {
      print(e);
      throw (e.toString());
    }
  }

  void replyToMessage(WebSocketChannel conn, String channel, Map message,
      String conversationId, String replyTo, String senderToken) {
    Map msg = {
      'type': 1,
      'channel': channel,
      'content': message,
      'sender_token': senderToken,
      'conversation_id': conversationId,
      'reply_to': replyTo,
      'is_reply': true,
    };
    conn.sink.add(json.encode(msg));
  }

  Future replyMessageWithAttachment(String userToken, String messageId,
      String conversationId, String? filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/chat/message/send/attachment/reply'),
      );
      request.headers.addAll({
        "x-api-key": _secret,
      });
      request.fields.addAll({
        'sender_token': userToken,
        'message_id': messageId,
        'conversation_id': conversationId,
      });
      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            filePath,
          ),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final dynamic res = json.decode(response.body);
      final int statusCode = response.statusCode;
      if (statusCode == 401) {
        throw ("Unauthorized");
      } else if (statusCode < 200 || statusCode > 400 || json == null) {
        throw ("${res["message"]}");
      }
      return res;
    } catch (e) {
      print(e);
      throw (e.toString());
    }
  }

  Future reactToMessage(String reaction, String messageId,
      String conversationId, String senderToken) async {
    String now = DateTime.now().toString();
    now = now.replaceAll(" ", "T");
    var x = json.encode({
      "user_token": senderToken,
      "reaction": reaction,
      "conversation_id": conversationId,
      "timestamp": "2021-12-04T20:48:07.338Z",
    });
    print(x);
    try {
      http.Response response = await http.post(
          Uri.parse('$_baseUrl/chat/message/reaction/$messageId'),
          headers: {
            "x-api-key": _secret,
          },
          body: json.encode({
            "user_token": senderToken,
            "reaction": reaction,
            "conversation_id": conversationId,
            "timestamp": "2021-12-04T20:48:07.338Z",
          }));
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        print(res);
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future removeReaction(String reactionId, String messageId,
      String conversationId, String senderToken) async {
    try {
      http.Response response = await http.delete(
          Uri.parse(
              '$_baseUrl/chat/message/reaction/delete/$reactionId/$messageId'),
          headers: {
            "x-api-key": _secret,
          });
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future sendReadReceipts(
      List<String> messageIds, String conversationId) async {
    try {
      http.Response response =
          await http.post(Uri.parse('$_baseUrl/chat/message/read/receipt'),
              headers: {
                "x-api-key": _secret,
              },
              body: json.encode({
                "message_ids": messageIds,
                "conversation_id": conversationId,
              }));
      final String res = response.body;
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        print("Error while fetching data");
      } else {
        print(res);
        return _decoder.convert(res)['data'];
      }
    } catch (e) {
      print(e.toString());
    }
  }

  close(WebSocketChannel conn) {
    conn.sink.close();
  }
}
