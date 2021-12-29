import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';

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
  return formattedDate;
}

IconButton goBack(BuildContext context){
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