import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String baseUrl = "api.robinapp.co";
const String httpUrl = "https://$baseUrl/api/v1";
const String wsUrl = 'wss://$baseUrl/ws';

const String robinChannel = 'private_chat';

DateFormat dateFormat = DateFormat('HH:mm');

const Color white = Color(0XFFFFFFFF);
const Color black = Color(0XFF000000);
const Color blueGrey = Color(0XFF535F89);
const Color green = Color(0XFF15AE73);
const Color red = Color(0XFFD53120);
const Color robinOrange = Color(0XFFEA8D51);

const List<Color> groupUserColors = [
  Color(0XFFF8863D),
  Color(0XFF18C583),
  Color(0XFFFF0000),
  Color(0XFF0F0FFE),
  Color(0XFF9B2226),
  Color(0XFFAE2012),
  Color(0XFFBB3E03),
  Color(0XFFCA6702),
  Color(0XFF7F5539),
  Color(0XFF606C38),
  Color(0XFF283618),
  Color(0XFF03045E),
  Color(0XFF370617),
  Color(0XFF6A040F),
  Color(0XFFEE9B00),
  Color(0XFF0A9396),
  Color(0XFF005F73),
  Color(0XFF0AFF99),
  Color(0XFF9D4EDD),
  Color(0XFF7400B8),
  Color(0XFF6B705C),
  Color(0XFFCB997E),
  Color(0XFFA4133C),
  Color(0XFF38B000),
  Color(0XFF14213D),
  Color(0XFF007200),
  Color(0XFF7209B7),
  Color(0XFF3D405B),
  Color(0XFF8338EC),
  Color(0XFF3A86FF),
  Color(0XFF5A189A),
  Color(0XFF3C096C),
];

const List<String> reactions = ['⁉️', '😂', '❤️', '👍', '👎'];

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
