import 'package:flutter/material.dart';

class RobinOptions{
  Widget? appIcon;
  bool? canCreateGroupChats;
  bool? canForwardMessages;
  bool? canDeleteMessages;
  String? deviceToken;
  String? fcmKey;


  RobinOptions({
    this.appIcon,
    this.canCreateGroupChats,
    this.canForwardMessages,
    this.canDeleteMessages,
    this.deviceToken,
    this.fcmKey,
  });

}
