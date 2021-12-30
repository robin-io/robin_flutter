import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/views/robin_create_conversation.dart';

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

IconButton goBack(BuildContext context) {
  return IconButton(
    icon: const Icon(
      Icons.arrow_back_ios,
      size: 16,
      color: Color(0XFF535F89),
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
