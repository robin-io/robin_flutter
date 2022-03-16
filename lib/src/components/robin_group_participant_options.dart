import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/utils/constants.dart';

class RobinGroupParticipantOptions extends StatelessWidget {
  final Map participant;

  const RobinGroupParticipantOptions({Key? key, required this.participant})
      : super(key: key);

  void confirmRemoveGroupParticipant(BuildContext context, Map participant) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: const Color(0XFFF2F2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Confirm Removal',
                      style: TextStyle(
                        color: black,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        'Do you want to remove ${participant['meta_data']['display_name']} from the ${rc.currentConversation.value.name} Group',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0XFFB0B0B3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0XFFD53120),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                rc.removeGroupParticipant(
                                    participant['user_token']);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Proceed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void confirmMakeGroupModerator(BuildContext context, Map participant) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: const Color(0XFFF2F2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Make Moderator',
                      style: TextStyle(
                        color: black,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        'Do you want to make ${participant['meta_data']['display_name']} a moderator in the ${rc.currentConversation.value.name} Group',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0XFFB0B0B3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0XFFD53120),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                rc.assignGroupModerator(
                                    participant['user_token']);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Proceed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void confirmDismissGroupModerator(BuildContext context, Map participant) {
    showDialog(
      context: context,
      builder: (_) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 270,
                decoration: BoxDecoration(
                  color: const Color(0XFFF2F2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Dismiss Moderator',
                      style: TextStyle(
                        color: black,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        'Do you want to remove ${participant['meta_data']['display_name']} as a moderator in the ${rc.currentConversation.value.name} Group',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Color(0XFFB0B0B3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0XFFD53120),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                rc.assignGroupModerator(
                                    participant['user_token']);
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 0.5,
                                      color: Color(0XFFB0B0B3),
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Proceed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: Color(0XFFF1F1F1),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${participant['meta_data']['display_name']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                participant['is_moderator']
                    ? Container()
                    // InkWell(
                    //         onTap: () {
                    //           confirmDismissGroupModerator(context, participant);
                    //         },
                    //         child: Container(
                    //           decoration: const BoxDecoration(
                    //             border: Border(
                    //               bottom: BorderSide(
                    //                 width: 1,
                    //                 color: Color(0XFFF1F1F1),
                    //               ),
                    //             ),
                    //           ),
                    //           child: Padding(
                    //             padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    //             child: Row(
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: const [
                    //                 Expanded(
                    //                   child: Text(
                    //                     'Dismiss As Moderator',
                    //                     overflow: TextOverflow.ellipsis,
                    //                     textAlign: TextAlign.center,
                    //                     maxLines: 1,
                    //                     style: TextStyle(
                    //                       fontSize: 18,
                    //                       color: red,
                    //                       fontWeight: FontWeight.w500,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    : InkWell(
                        onTap: () {
                          confirmMakeGroupModerator(context, participant);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0XFFF1F1F1),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Expanded(
                                  child: Text(
                                    'Make Group Moderator',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                InkWell(
                  onTap: () {
                    confirmRemoveGroupParticipant(context, participant);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Color(0XFFF1F1F1),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Expanded(
                            child: Text(
                              'Remove From Group',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 18,
                                color: red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Expanded(
                          child: Text(
                            'Cancel',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 18,
                              color: black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
