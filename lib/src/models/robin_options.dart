import 'package:flutter/material.dart';

class RobinOptions{
  Widget? appIcon;
  bool? canCreateGroupChats;
  bool? canForwardMessages;
  bool? canDeleteMessages;
  bool? canDeleteConversations;
  String? deviceToken;
  String? fcmKey;
  int? maxDeleteDuration;


  RobinOptions({
    this.appIcon,
    this.canCreateGroupChats,
    this.canForwardMessages,
    this.canDeleteMessages,
    this.canDeleteConversations,
    this.deviceToken,
    this.fcmKey,
    this.maxDeleteDuration,
  });

}
