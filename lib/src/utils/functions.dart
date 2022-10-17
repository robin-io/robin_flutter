import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:linkify/linkify.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robin_flutter/src/views/robin_send_image.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/models/robin_message_reaction.dart';
import 'package:robin_flutter/src/components/robin_create_group.dart';
import 'package:robin_flutter/src/components/robin_conversation_info.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/components/robin_create_conversation.dart';
import 'package:robin_flutter/src/components/message-group/url-preview/url_preview.dart';
import 'package:robin_flutter/src/components/robin_add_group_participants.dart';
import 'package:robin_flutter/src/components/robin_conversation_media.dart';
import 'package:robin_flutter/src/components/robin_encryption_details.dart';
import 'package:robin_flutter/src/components/robin_group_participant_options.dart';
import 'package:robin_flutter/src/components/robin_select_group_participants.dart';
import 'package:robin_flutter/src/components/robin_media_options.dart';
import 'package:http/http.dart' as http;

final RobinController rc = Get.find();

void getMessageQueue() async {
  final prefs = await SharedPreferences.getInstance();
  String encodedMessageQueue =
      prefs.getString('robinMessageQueue${rc.currentUser!.robinToken}') ?? '{}';
  Map<String, Map> messageQueue =
      Map<String, Map>.from(json.decode(encodedMessageQueue));
  rc.messageQueue = messageQueue;
  print(messageQueue);
}

void addToMessageQueue(String messageId, Map message) {
  print(message);
  Map conversationQueue = rc.messageQueue[message['conversation_id']] ?? {};
  conversationQueue = {...conversationQueue, messageId: message};
  rc.messageQueue[message['conversation_id']] = conversationQueue;
  updateMessageQueue();
}

void removeFromMessageQueue(Map message) {
  if (rc.messageQueue.containsKey(message['conversation_id'])) {
    Map conversationQueue = rc.messageQueue[message['conversation_id']] ?? {};
    conversationQueue.remove(message['content']['local_id']);
    rc.messageQueue[message['conversation_id']] = conversationQueue;
  }
  updateMessageQueue();
}

void updateMessageQueue() async {
  final prefs = await SharedPreferences.getInstance();
  String encodedMessageQueue = json.encode(rc.messageQueue);
  await prefs.setString(
      'robinMessageQueue${rc.currentUser!.robinToken}', encodedMessageQueue);
  print(encodedMessageQueue);
}

void sendAllInMessageQueue() async{
  List<Map> dequeue = [];
  for(Map conversationMessagesInQueue in rc.messageQueue.values.toList()){
    for (Map message in conversationMessagesInQueue.values.toList()) {
      if (message['content']['is_attachment']) {
        rc.isFileSending.value = true;
        if (message['reply_to'] != null) {
          Map<String, String> body = {
            'conversation_id': message['conversation_id'],
            'message_id': message['reply_to'],
            'sender_token': message['sender_token'],
            'sender_name': message['sender_token'],
            'msg': message['content']['msg'],
            'timestamp': DateTime.now().toString(),
            'file_path': message['content']['attachment'],
            'local_id': message['_id'],
          };
          List<http.MultipartFile> files = [
            await http.MultipartFile.fromPath(
              'file',
              message['content']['attachment'],
            ),
          ];
          rc.robinCore!.replyWithAttachment(body, files, message);
          rc.isFileSending.value = false;
        } else {
          Map<String, String> body = {
            'conversation_id': message['conversation_id'],
            'sender_token': message['sender_token'],
            'sender_name': message['sender_token'],
            'msg': message['content']['msg'],
            'timestamp': DateTime.now().toString(),
            'file_path': message['content']['attachment'],
            'local_id': message['_id'],
          };
          List<http.MultipartFile> files = [
            await http.MultipartFile.fromPath(
              'file',
              message['content']['attachment'],
            ),
          ];
          rc.robinCore!.sendAttachment(body, files, message);
          rc.isFileSending.value = false;
        }
        dequeue.add(message);
      } else {
        Map<String, String> msg = {
          'msg': message['content']['msg'],
          'timestamp': DateTime.now().toString(),
          'sender_token': message['sender_token'],
          'sender_name': message['sender_token'],
          'local_id': message['_id']
        };
        if (message['reply_to'] != null) {
          rc.robinCore!.replyToMessage(
              msg,
              message['conversation_id'],
              rc.currentUser!.robinToken,
              rc.currentUser!.fullName,
              message['reply_to']);
        } else {
          rc.robinCore!.sendTextMessage(
            msg,
            message['conversation_id'],
            rc.currentUser!.robinToken,
            rc.currentUser!.fullName,
          );
        }
        dequeue.add(message);
      }
    }
  }
  for(Map msg in dequeue){
    removeFromMessageQueue(msg);
  }
}

void showErrorMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: const Color(0XFFFF3B30),
    textColor: const Color(0XFFFFFFFF),
    fontSize: 16.0,
  );
}

void showSuccessMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: green,
    textColor: const Color(0XFFFFFFFF),
    fontSize: 16.0,
  );
}

bool switchToCol(double width, int chars) {
  bool shouldSwitch = false;
  if ((width / 14) * 1.5 > chars) {
    return true;
  }
  return shouldSwitch;
}

String formatDate(String dateString) {
  String formattedDate = Jiffy(dateString).fromNow();
  formattedDate = formattedDate.replaceAll(' ago', '');
  formattedDate = formattedDate.replaceAll('a few seconds', 'few seconds');
  formattedDate = formattedDate.replaceAll("a day", 'Yesterday');
  return formattedDate;
}

String formatTimestamp(DateTime dateTime) {
  final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (date == today) {
    return 'Today';
  }
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (date == yesterday) {
    return 'Yesterday';
  }
  if (date.year == now.year) {
    final DateFormat formatter = DateFormat('E, d MMM');
    return formatter.format(date);
  }
  final DateFormat formatter = DateFormat('d MMM y');
  return formatter.format(date);
}

IconButton backButton(BuildContext context, {IconData? icon, double? size}) {
  return IconButton(
    icon: Icon(
      icon ?? Icons.arrow_back_ios,
      size: size ?? 16,
      color: const Color(0XFF535F89),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}

IconButton closeButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF6B7491),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.close,
        size: 18,
        color: Colors.white,
      ),
    ),
  );
}

void showCreateConversation(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const RobinCreateConversation(),
  );
}

void showCreateGroupChat(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => RobinCreateGroup(),
  );
}

bool checkDeleteDuration(DateTime timestamp){
  if (rc.maxDelete){
    DateTime now = DateTime.now();
    return now.difference(timestamp).inSeconds < rc.maxDeleteDuration;
  }
  return true;
}

void showConversationInfo(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => RobinConversationInfo(),
  );
}

void showSelectGroupParticipants(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const RobinSelectGroupParticipants(),
  );
}

void showAddGroupParticipants(
    BuildContext context, List<String> existingParticipants) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => RobinAddGroupParticipants(
      existingParticipants: existingParticipants,
    ),
  );
}

void showEncryptionDetails(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const RobinEncryptionDetails(),
  );
}

void showConversationMedia(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => RobinConversationMedia(),
  );
}

void showGroupParticipantOptions(BuildContext context, Map participant) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => RobinGroupParticipantOptions(participant: participant),
  );
}

InputDecoration textFieldDecoration({double? radius, int? style}) {
  radius = radius ?? 4;
  OutlineInputBorder border = textFieldBorder.copyWith(
    borderRadius: BorderRadius.circular(radius),
    borderSide: const BorderSide(style: BorderStyle.none),
  );
  OutlineInputBorder outlinedBorder = textFieldBorder.copyWith(
    borderRadius: BorderRadius.circular(radius),
    borderSide: const BorderSide(width: 1, color: Color(0XFF9999BC)),
  );
  return InputDecoration(
    hintStyle: const TextStyle(
      color: Color(0XFF8D9091),
      fontSize: 16,
    ),
    contentPadding: const EdgeInsets.all(15.0),
    filled: true,
    fillColor: const Color(0XFFF5F7FC),
    border: style == null || style == 1 ? border : outlinedBorder,
    focusedBorder: style == null || style == 1 ? border : outlinedBorder,
    enabledBorder: style == null || style == 1 ? border : outlinedBorder,
  );
}

//Let the user choose if they want to either
//send  a picture or a video
void showMediaOptions(BuildContext context, String source) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => RobinMediaOptions(source: source),
  );
}

getMedia(BuildContext context,
    {required String source, bool? isGroup, bool? isVideo}) async {
  final ImagePicker picker = ImagePicker();
  if (isGroup != null && isGroup == true) {
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );
    if (file != null) {
      rc.groupIcon.value = {
        'file': file,
      };
    }
  } else {
    if (source == 'gallery') {
      if (isVideo != null && isVideo) {
        final XFile? video =
            await picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          rc.file.value = [video];
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RobinSendMedia(
                isVideo: true,
              ),
            ),
          );
        }
      } else {
        final List<XFile>? images = await picker.pickMultiImage(
          imageQuality: 10,
        );
        if (images != null) {
          rc.file.value = images;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RobinSendMedia(),
            ),
          );
        }
      }
    } else {
      if (isVideo != null && isVideo) {
        final XFile? video = await picker.pickVideo(source: ImageSource.camera);
        if (video != null) {
          rc.file.value = [video];
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RobinSendMedia(isVideo: true),
            ),
          );
        }
      } else {
        XFile? file = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 10,
        );
        if (file != null) {
          rc.file.value = [file];
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RobinSendMedia(),
            ),
          );
        }
      }
    }
  }
}

getDocument() async {
  FilePickerResult? document = await FilePicker.platform.pickFiles();
  if (document != null) {
    rc.file.value = [document.files.first];
  }
}

String fileType({String? path}) {
  String filePath = path ?? rc.file[0].path;
  String? ext = filePath.split('.').last.toLowerCase();

  if (imageFormats.contains(ext)) {
    return 'image';
  }
  if (videoFormats.contains(ext)) {
    return 'video';
  }
  if (audioFormats.contains(ext)) {
    return 'audio';
  } else if (supportedFormats.contains(ext)) {
    return ext.toString();
  }
  return 'generic';
}

String formatISOTime(DateTime date) {
  var duration = date.timeZoneOffset;
  if (duration.isNegative) {
    return (date.toIso8601String() +
        '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}');
  } else {
    return (date.toIso8601String() +
        '+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}');
  }
}

String fileName(String path) {
  return path.split('/').last;
}

List<LinkifyElement> matchLinks(String str) {
  List<LinkifyElement> x = linkify(str);
  List<LinkifyElement> formattedStrings = linkify(
    str,
    options: const LinkifyOptions(
      looseUrl: true,
      humanize: true,
      removeWww: false,
      excludeLastPeriod: true,
    ),
  );
  for (int i = 0; i < x.length; i++) {
    if (x[i] is EmailElement) {
      formattedStrings[i] = x[i];
    }
  }
  return formattedStrings;
}

void _launchURL(String url, bool isMail) async {
  if (isMail) {
    final Uri params = Uri(
      scheme: 'mailto',
      path: url,
    );
    url = params.toString();
  }
  await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}

Widget formatText(String string, {bool? truncate}) {
  var formattedTexts = matchLinks(string);
  return RichText(
    maxLines: truncate != null && truncate ? 7 : null,
    overflow: truncate != null && truncate
        ? TextOverflow.ellipsis
        : TextOverflow.visible,
    text: TextSpan(
      children: [
        for (LinkifyElement formattedText in formattedTexts)
          formattedText is EmailElement
              ? WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      _launchURL(formattedText.text, true);
                    },
                    child: Text(
                      formattedText.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: Color(0XFF4568D1),
                      ),
                    ),
                  ),
                )
              : formattedText is UrlElement
                  ? WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          _launchURL(formattedText.url, false);
                        },
                        child: Text(
                          formattedText.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: Color(0XFF4568D1),
                          ),
                        ),
                      ),
                    )
                  : TextSpan(
                      text: formattedText.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: Color(0XFF101010),
                      ),
                    ),
      ],
    ),
  );
}

Widget getURLPreview(String string) {
  var formattedTexts = matchLinks(string);
  String firstLink = '';
  for (LinkifyElement formattedText in formattedTexts) {
    if (formattedText is UrlElement) {
      firstLink = formattedText.url;
      break;
    }
  }
  return firstLink.isNotEmpty
      ? Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: UrlPreview(
            url: firstLink,
            key: Key(firstLink),
          ),
        )
      : Container(
          width: 0,
        );
}

String getTimestamp() {
  String timestamp = DateTime.now().toString();
  timestamp = timestamp.substring(0, timestamp.length - 3);
  timestamp = timestamp.replaceAll(" ", 'T');
  timestamp += 'Z';
  return timestamp;
}

List<Map<String, RobinMessageReaction>> getReactions(List reactions) {
  Map<String, RobinMessageReaction> allReactions = {};
  Map<String, RobinMessageReaction> myReactions = {};
  for (Map reaction in reactions) {
    RobinMessageReaction robinReaction =
        RobinMessageReaction.fromJson(reaction);
    if (robinReaction.userToken == rc.currentUser?.robinToken) {
      myReactions[robinReaction.type] = robinReaction;
    }
    if (allReactions[robinReaction.type] == null) {
      allReactions[robinReaction.type] = robinReaction;
    } else {
      robinReaction.number = allReactions[robinReaction.type]!.number += 1;
      allReactions[robinReaction.type] = robinReaction;
    }
  }
  return [allReactions, myReactions];
}

Map localRobinMessageJson(
  Map message,
  String conversationId,
  String senderToken,
  String senderName, {
  String? replyTo,
  bool? isAttachment,
  String? filePath,
}) {
  return {
    "_id": message['local_id'],
    'conversation_id': conversationId,
    "content": {
      'is_attachment': isAttachment ?? false,
      'attachment': isAttachment == null || !isAttachment ? '' : filePath,
      'msg': message['msg'],
      'sender_token': senderToken,
      'sender_name': senderName,
      'local_id': message['local_id'],
      'file_path': filePath
    },
    'sender_token': senderToken,
    'sender_name': senderName,
    'is_forwarded': false,
    'reply_to': replyTo,
    'is_read': false,
    'reactions': [],
    'deleted_for': [],
    'created_at': message['timestamp']
  };
}

void showChatOptions(OverlayEntry entry) {
  rc.chatOptionsEntry = entry;
  rc.chatOptionsOpened.value = true;
}

void disposeChatOptions() {
  rc.chatOptionsEntry?.remove();
  rc.chatOptionsOpened.value = false;
  rc.chatOptionsEntry = null;
}

String reactionToText(String value) {
  String reaction = '';
  switch (value) {
    case '⁉️':
      reaction = 'exclaim';
      break;
    case '😂':
      reaction = 'laugh';
      break;
    case '❤️':
      reaction = 'heart';
      break;
    case '👍':
      reaction = 'thumbs_up';
      break;
    case '👎':
      reaction = 'thumbs_down';
      break;
    default:
      break;
  }
  return reaction;
}

/// To group a series of images together while rendering
/// They have to be sent by the same person,
/// be a reply to either the same message or none
/// be sent in the same day
/// This function carries out all those checks
bool similarImageCheck(RobinMessage imageOne, RobinMessage imageTwo) {
  return imageOne.senderToken == imageTwo.senderToken &&
      imageOne.replyTo == imageTwo.replyTo &&
      dayFromDateTime(imageOne.timestamp) ==
          dayFromDateTime(imageTwo.timestamp);
}

String dayFromDateTime(DateTime timestamp) {
  return '${timestamp.year}/${timestamp.day}';
}

void updateLocalConversations() async {
  String userToken = rc.currentUser!.robinToken;
  String fileName = 'userDetails$userToken.json';
  var dir = await getTemporaryDirectory();
  File file = File(dir.path + '/$fileName');
  List<Map> conversationsList = [];
  for (RobinConversation conversation in rc.allConversations.values.toList()) {
    conversationsList.add(conversation.toJson());
  }
  file.writeAsStringSync(
    jsonEncode({
      'data': {
        'conversations': conversationsList,
      },
    }),
    flush: true,
    mode: FileMode.write,
  );
}

void updateLocalConversationMessages(String conversationId, Map message) async {
  if (conversationId.isNotEmpty) {
    String userToken = rc.currentUser!.robinToken;
    String fileName = 'conversation$conversationId$userToken.json';
    var dir = await getTemporaryDirectory();
    File file = File(dir.path + '/$fileName');
    List messagesList = [];
    if (file.existsSync()) {
      final fileData = file.readAsStringSync();
      final response = jsonDecode(fileData);
      messagesList = response['data'];
    }
    if (message.isNotEmpty) {
      messagesList.add(message);
    }
    file.writeAsStringSync(
      jsonEncode({
        'data': messagesList,
      }),
      flush: true,
      mode: FileMode.write,
    );
  }
}
