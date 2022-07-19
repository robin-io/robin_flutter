import 'dart:ui';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';

import '../../utils/constants.dart';
import '../../utils/functions.dart';

class MessageReactions extends StatefulWidget {
  final RobinMessage message;
  final OverlayEntry? entry;

  const MessageReactions({
    Key? key,
    required this.message,
    required this.entry,
  }) : super(key: key);

  @override
  State<MessageReactions> createState() => _MessageReactionsState();
}

class _MessageReactionsState extends State<MessageReactions> {
  final RobinController rc = Get.find();

  bool _expand = false;

  _startAnimation() {
    Future.delayed(const Duration(milliseconds: 20), () {
      setState(() {
        _expand = true;
      });
    });
  }

  @override
  void initState() {
    _startAnimation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 195),
      width: _expand ? 218 : 35,
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(1.5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (String reaction in reactions)
              Padding(
                padding: const EdgeInsets.all(1.5),
                child: GestureDetector(
                  onTap: () {
                    if (widget.message.myReactions.keys
                        .contains(reaction)) {
                      rc.removeReaction(
                          widget.message.id,
                          widget
                              .message.myReactions[reaction]!.id);
                    } else {
                      rc.sendReaction(
                          reaction, widget.message.id);
                    }
                    widget.entry?.remove();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.message.myReactions.keys
                          .contains(reaction)
                          ? robinOrange
                          : null,
                    ),
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      'assets/images/reactions/${reactionToText(reaction)}.png',
                      package: 'robin_flutter',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
