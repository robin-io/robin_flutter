import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String baseUrl = "api.robinapp.co";
const String httpUrl = "https://$baseUrl/api/v1";
const String wsUrl = 'wss://$baseUrl/ws';

const String robinChannel = 'private_chat';

DateFormat dateFormat = DateFormat('hh:mm');

const Color white = Color(0XFFFFFFFF);
const Color black = Color(0XFF000000);
const Color blueGrey = Color(0XFF535F89);
const Color green = Color(0XFF15AE73);
const Color robinOrange = Color(0XFFEA8D51);

const List<Color> groupUserColors = [
  Color(0XFFF8863D),
  Color(0XFF18C583),
  Color(0XFFFF0000),
  Color(0XFF0F0FFE)
];

const List<String> reactions = ['exclaim', 'laugh', 'heart', 'thumbs_up', 'thumbs_down'];

const List<String> imageFormats = ['png', 'jpg', 'jpeg', 'gif', 'heic'];
const List<String> audioFormats = [
  'mp3',
  'm4a',
  'ogg',
  'wav',
  'flac',
  'aac',
  'wma'
];
const List<String> supportedFormats = [
  'pdf',
  'odt',
  'md',
  'txt',
  'rtf',
  'doc',
  'docx',
  'ppt',
  'pptx',
  'zip',
  'rar',
  'html',
  'csv',
  'xls',
  'xlsx'
];

OutlineInputBorder textFieldBorder = OutlineInputBorder(
  borderSide: const BorderSide(
    width: 1,
    style: BorderStyle.solid,
    color: Color(0XFFCADAF8),
  ),
  borderRadius: BorderRadius.circular(4),
);
