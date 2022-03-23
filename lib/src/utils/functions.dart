import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:linkify/linkify.dart';
import 'package:flutter/material.dart';
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

final RobinController rc = Get.find();

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
    builder: (_) => RobinCreateConversation(),
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
    builder: (_) => RobinSelectGroupParticipants(),
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

getMedia(BuildContext context, {required String source, bool? isGroup}) async {
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
      final List<XFile>? images = await picker.pickMultiImage(
        imageQuality: 10,
      );
      if (images != null) {
        rc.file.value = images;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RobinSendImage(),
          ),
        );
      }
    } else {
      XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 10,
      );
      if (file != null) {
        rc.file.value = [file];
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
        '-${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}');
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
    print(reaction);
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
