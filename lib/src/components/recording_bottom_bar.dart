import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';

class RecordingBottomBar extends StatefulWidget {
  const RecordingBottomBar({Key? key}) : super(key: key);

  @override
  State<RecordingBottomBar> createState() => _RecordingBottomBarState();
}

class _RecordingBottomBarState extends State<RecordingBottomBar> {
  final RobinController rc = Get.find();

  int recordDuration = 0;

  Timer? timer;

  Recording? recording;

  initialize() async {
    bool? hasPermission = await FlutterAudioRecorder2.hasPermissions;
    if (hasPermission != null && hasPermission) {
      await rc.recorder.initialized;
      recordDuration = 0;
      recording = await rc.recorder.current(channel: 0);
      if (recording?.status != RecordingStatus.Recording) {
        await rc.recorder.start();
        timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
          if (mounted) {
            setState(() {
              recordDuration += 1;
              print(formatTime(recordDuration));
              print(recording?.status);
            });
          }
          print('yah');
        });
      }
    }
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'
        .split('.')[0]
        .padLeft(8, '0')
        .substring(3);
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  disposeRecorder() async {
    var result = await rc.recorder.stop();
    timer?.cancel();
    rc.isRecording.value = false;
  }

  @override
  void dispose() {
    disposeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            disposeRecorder();
          },
          child: const Icon(
            Icons.clear,
            size: 24,
            color: Color(0XFFD53120),
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Container(
          height: 52,
          width: 249,
          color: Colors.red,
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          formatTime(recordDuration),
          style: const TextStyle(
            fontSize: 13,
            color: green,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            if (!rc.isFileSending.value) {
              if (rc.file['file'] != null) {
                if (rc.replyView.value) {
                  rc.sendReplyAsAttachment();
                } else {
                  rc.sendAttachment();
                }
              } else if (rc.messageController.text.isNotEmpty) {
                if (rc.replyView.value) {
                  rc.sendReplyAsTextMessage();
                } else {
                  rc.sendTextMessage();
                }
              }
            }
          },
          child: Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0XFF15AE73),
              shape: BoxShape.circle,
            ),
            child: rc.isFileSending.value
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0XFFFFFFFF),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: SvgPicture.asset(
                      'assets/icons/send.svg',
                      package: 'robin_flutter',
                      semanticsLabel: 'edit',
                      width: 22,
                      height: 22,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
