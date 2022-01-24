import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:linkify/linkify.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:robin_flutter/src/components/robin_select_group_participants.dart';
import 'package:robin_flutter/src/models/robin_message_reaction.dart';
import 'package:robin_flutter/src/components/robin_create_group.dart';
import 'package:robin_flutter/src/views/robin_conversation_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/components/robin_create_conversation.dart';
import 'package:robin_flutter/src/components/message-group/url-preview/url_preview.dart';

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

String formatDate(String dateString) {
  String formattedDate = Jiffy(dateString).fromNow();
  formattedDate = formattedDate.replaceAll(' ago', '');
  formattedDate = formattedDate.replaceAll('a few seconds', 'few seconds');
  return formattedDate;
}

IconButton backButton(BuildContext context, {IconData? icon, double? size}) {
  return IconButton(
    icon:  Icon(
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

getMedia({required String source}) async {
  ImageSource imageSource = ImageSource.camera;
  if (source == 'gallery') {
    imageSource = ImageSource.gallery;
  }
  final ImagePicker picker = ImagePicker();
  rc.file.value = {
    'file': await picker.pickImage(
      source: imageSource,
      imageQuality: 10,
    )
  };
}

getDocument() async {
  FilePickerResult? document = await FilePicker.platform.pickFiles();
  rc.file.value = {'file': document?.files.first};
}

String fileType({String? path}) {
  String filePath = path ?? rc.file['file'].path;
  String? ext = filePath
      .split('.')
      .last
      .toLowerCase();

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

String fileName(String path) {
  return path
      .split('/')
      .last;
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

Widget formatText(String string) {
  var formattedTexts = matchLinks(string);
  return RichText(
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

Map<String, RobinMessageReaction> convertToReactions(List reactions) {
  Map<String, RobinMessageReaction> robinReactions = {};
  for (Map reaction in reactions) {
    RobinMessageReaction robinReaction = RobinMessageReaction.fromJson(reaction);
    robinReactions[robinReaction.type] = robinReaction;
  }
  return robinReactions;
}

void showChatOptions(OverlayEntry entry){
rc.chatOptionsEntry = entry;
rc.chatOptionsOpened.value = true;
}

void disposeChatOptions(){
  rc.chatOptionsEntry?.remove();
  rc.chatOptionsOpened.value = false;
  rc.chatOptionsEntry = null;
}