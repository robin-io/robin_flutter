import 'package:flutter/material.dart';

const String baseUrl = "api.robinapp.co";
const String httpUrl = "https://$baseUrl/api/v1";
const String wsUrl = 'wss://$baseUrl/ws';

const String robinChannel = 'private_chat';

const Color white = Color(0XFFFFFFFF);
const Color blueGrey = Color(0XFF535F89);
const Color green = Color(0XFF15AE73);

OutlineInputBorder textFieldBorder = OutlineInputBorder(
  borderSide: const BorderSide(
    width: 1,
    style: BorderStyle.solid,
    color: Color(0XFFCADAF8),
  ),
  borderRadius: BorderRadius.circular(4),
);

InputDecoration textFieldDecoration = InputDecoration(
  hintStyle: const TextStyle(
    color: Color(0XFFBBC1D6),
    fontSize: 16,
  ),
  contentPadding: const EdgeInsets.all(15.0),
  filled: true,
  fillColor: const Color(0XFFF4F6F8),
  border: textFieldBorder,
  focusedBorder: textFieldBorder,
  enabledBorder: textFieldBorder,
);

