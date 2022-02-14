import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:record/record.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

class RecordingBottomBar extends StatefulWidget {
  const RecordingBottomBar({Key? key}) : super(key: key);

  @override
  State<RecordingBottomBar> createState() => _RecordingBottomBarState();
}

class _RecordingBottomBarState extends State<RecordingBottomBar> {
  final RobinController rc = Get.find();

  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;

  final Record _recorder = Record();
  Amplitude? _amplitude;

  List<Widget> _ampBars = [];

  initialize() async {
    bool hasPermission = await _recorder.hasPermission();
    if (hasPermission) {
      Directory tempDir = await getTemporaryDirectory();
      String path = tempDir.path + '/voice_note.m4a';
      await _recorder.start(path: path);
      _recordDuration = 0;
      _startTimer();
    } else {
      rc.isRecording.value = false;
    }
  }

  void _startTimer() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    _ampBars = [];
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration += 1;
      });
    });
    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 100), (Timer t) async {
      _amplitude = await _recorder.getAmplitude();
      setState(() {
        _ampBars.add(
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Container(
              width: 2,
              height: getAmpHeight(_amplitude?.current),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
                color: const Color(0XFF9999BC),
              ),
            ),
          ),
        );
      });
    });
  }

  double getAmpHeight(double? amp) {
    if (amp == null) {
      return 3;
    }

    if (amp > -1.1) {
      return 52;
    }
    if (amp < -39) {
      return 3;
    }
    amp = (amp).abs();
    if (amp < 5) {
      return 47;
    } else if (amp < 10) {
      return 30;
    } else if (amp < 13) {
      return 27;
    } else if (amp < 15) {
      return 24;
    } else if (amp < 17) {
      return 20;
    } else if (amp < 20) {
      return 17;
    } else if (amp < 23) {
      return 14;
    } else if (amp < 25) {
      return 12;
    } else if (amp < 27) {
      return 9;
    } else if (amp < 30) {
      return 6;
    } else if (amp < 35) {
      return 4;
    }
    return 3;
  }

  String _formatTime(int duration) {
    final String minutes = _formatNumber(duration ~/ 60);
    final String seconds = _formatNumber(duration % 60);
    return '$minutes:$seconds';
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }
    return numberStr;
  }

  void sendVoiceNote() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _recorder.stop();
    try {
      if (rc.replyView.value) {
        await rc.sendReplyAsAttachment(path: path);
      } else {
        await rc.sendAttachment(path: path);
      }
      rc.isRecording.value = false;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              _recorder.stop();
              rc.isRecording.value = false;
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: _ampBars.reversed.toList(),
              ),
            ),
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            _formatTime(_recordDuration),
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
                sendVoiceNote();
              }
            },
            child: Obx(
              () => Container(
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
          ),
        ],
      ),
    );
  }
}
