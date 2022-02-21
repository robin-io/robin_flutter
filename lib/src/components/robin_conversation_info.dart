import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/components/message-group/text_bubble.dart';
import 'package:robin_flutter/src/components/user_avatar.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:robin_flutter/src/views/robin_image_preview.dart';

class RobinConversationInfo extends StatelessWidget {
  final RobinController rc = Get.find();

  RobinConversationInfo({Key? key}) : super(key: key) {
    rc.getConversationInfo();
    print(rc.currentConversation);
  }

  RxBool seeAllParticipants = false.obs;

  List<String> getParticipantsRobinToken() {
    List<String> participants = [];
    for (Map user in rc.currentConversation.value.participants!) {
      participants.add(user['user_token']);
    }
    return participants;
  }

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

  Widget renderPhotos(BuildContext context) {
    if (rc.currentConversationInfo['photos'] == null ||
        rc.currentConversationInfo['photos'].isEmpty) {
      return const Center(
        child: Text(
          'No Photos',
          style: TextStyle(
            color: black,
            fontSize: 16,
          ),
        ),
      );
    } else {
      List<Widget> docs = [];
      for (int i = 0; i < rc.currentConversationInfo['photos'].length; i++) {
        Map doc = rc.currentConversationInfo['photos'][i];
        RobinMessage message = RobinMessage.fromJson(doc);
        docs.add(
          GestureDetector(
            onTap: () {
              showGeneralDialog(
                barrierLabel: "Label",
                barrierDismissible: false,
                barrierColor: Colors.transparent,
                transitionDuration: const Duration(milliseconds: 200),
                context: context,
                pageBuilder: (context, anim1, anim2) {
                  return Dismissible(
                    direction: DismissDirection.vertical,
                    key: const Key('image_carousel'),
                    onDismissed: (_) => Navigator.of(context).pop(),
                    child: Material(
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            CarouselSlider.builder(
                                itemCount:
                                    rc.currentConversationInfo['photos'].length,
                                options: CarouselOptions(
                                  initialPage: i,
                                  height: MediaQuery.of(context).size.height,
                                  viewportFraction: 1,
                                  enableInfiniteScroll: false,
                                  autoPlay: false,
                                  scrollDirection: Axis.horizontal,
                                ),
                                itemBuilder: (BuildContext context,
                                    int itemIndex, int pageViewIndex) {
                                  String link = RobinMessage.fromJson(
                                          rc.currentConversationInfo['photos']
                                              [itemIndex])
                                      .link;
                                  return CachedNetworkImage(
                                    imageUrl: link,
                                    fit: BoxFit.fitWidth,
                                    placeholder: (context, url) =>
                                        const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 15, 10),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0XFF15AE73),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  );
                                }),
                            SafeArea(
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6B7491),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position: Tween(
                            begin: const Offset(0, 1), end: const Offset(0, 0))
                        .animate(anim1),
                    child: child,
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Hero(
                tag: message.link,
                child: CachedNetworkImage(
                  imageUrl: message.link,
                  width: 80,
                  height: 63,
                  fit: BoxFit.fitHeight,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 15, 10),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0XFF15AE73),
                          ),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
        );
        docs.add(
          const SizedBox(
            width: 5,
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: SingleChildScrollView(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: docs,
          ),
        ),
      );
    }
  }

  Widget renderLinks() {
    if (rc.currentConversationInfo['links'] == null ||
        rc.currentConversationInfo['links'].isEmpty) {
      return const Center(
        child: Text(
          'No Links',
          style: TextStyle(
            color: black,
            fontSize: 16,
          ),
        ),
      );
    } else {
      List<Widget> links = [];
      for (Map link in rc.currentConversationInfo['links']) {
        links.add(
          TextBubble(
            message: RobinMessage.fromJson(link),
            lastInSeries: false,
            firstInSeries: false,
            maxWidth: double.infinity,
          ),
        );
        links.add(
          const SizedBox(
            height: 5,
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: links,
          ),
        ),
      );
    }
  }

  Widget renderDocs() {
    if (rc.currentConversationInfo['documents'] == null ||
        rc.currentConversationInfo['documents'].isEmpty) {
      return const Center(
        child: Text(
          'No Documents',
          style: TextStyle(
            color: black,
            fontSize: 16,
          ),
        ),
      );
    } else {
      List<Widget> docs = [];
      for (Map doc in rc.currentConversationInfo['documents']) {
        docs.add(
          TextBubble(
            message: RobinMessage.fromJson(doc),
            lastInSeries: false,
            firstInSeries: false,
            maxWidth: double.infinity,
          ),
        );
        docs.add(
          const SizedBox(
            height: 5,
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: docs,
          ),
        ),
      );
    }
  }

  Widget renderParticipants(BuildContext context) {
    List<Widget> participants = [];
    bool isModerator = false;
    rc.currentConversation.value.participants!.sort((a, b) {
      if (b['is_moderator']) {
        return 1;
      }
      return -1;
    });
    int currentUserIndex = 0;
    for (Map participant in rc.currentConversation.value.participants!) {
      if (participant['user_token'] == rc.currentUser!.robinToken) {
        isModerator = participant['is_moderator'];
        break;
      }
      currentUserIndex += 1;
    }
    if (isModerator) {
      participants.add(
        GestureDetector(
          onTap: () {
            showAddGroupParticipants(
              context,
              getParticipantsRobinToken(),
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
            decoration: const BoxDecoration(
              color: Color(0XFFFBFBFB),
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Color(0XFFF5F7FC),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/add_participant.svg',
                      package: 'robin_flutter',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'Add Group Participant',
                      style: TextStyle(
                        color: Color(0XFF51545C),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    Map currentUser =
        rc.currentConversation.value.participants![currentUserIndex];
    rc.currentConversation.value.participants!.removeAt(currentUserIndex);
    rc.currentConversation.value.participants!.insert(0, currentUser);
    int shownUsers = 0;
    for (Map participant in rc.currentConversation.value.participants!) {
      if (!seeAllParticipants.value && shownUsers >= 4) {
        break;
      }
      shownUsers += 1;
      bool isCurrentUser =
          participant['user_token'] == rc.currentUser!.robinToken;
      participants.add(
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Color(0XFFF1F3F8),
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            children: [
              UserAvatar(
                name: '${participant['meta_data']['display_name']}',
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isCurrentUser
                            ? '${participant['meta_data']['display_name']} (You)'
                            : '${participant['meta_data']['display_name']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 16,
                          color: black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    participant['is_moderator']
                        ? Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0XFFF5F7FC),
                              ),
                              padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                              child: const Text(
                                'moderator',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0XFF8D9091),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    !isCurrentUser && isModerator
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 16,
                              color: Color(0XFFD53120),
                            ),
                            onPressed: () {
                              confirmRemoveGroupParticipant(
                                  context, participant);
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (!seeAllParticipants.value) {
      participants.add(
        GestureDetector(
          onTap: () {
            seeAllParticipants.value = true;
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            color: const Color(0XFFFBFBFB),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'See All Participants',
                  style: TextStyle(
                    color: green,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    Widget allParticipants = Column(
      children: participants,
    );
    return allParticipants;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: MediaQuery.of(context).size.height - 70,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: rc.chatViewLoading.value ||
                rc.conversationInfoLoading.value
            ? const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      green,
                    ),
                  ),
                ),
              )
            : Column(
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
                      padding:
                          const EdgeInsets.fromLTRB(15, 10, 15, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 24,
                                color: Color(0XFF51545C),
                              ),
                              padding: const EdgeInsets.all(0),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            rc.currentConversation.value.isGroup!
                                ? 'Group Info'
                                : 'Chat Info',
                            style: const TextStyle(
                              color: black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          UserAvatar(
                            name: rc.currentConversation.value.name!,
                            conversationIcon: rc.currentConversation
                                .value.conversationIcon,
                            size: 75,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            rc.currentConversation.value.name!,
                            style: const TextStyle(
                              color: black,
                              fontSize: 16,
                            ),
                          ),
                          rc.currentConversation.value.isGroup!
                              ? const SizedBox(
                                  height: 7,
                                )
                              : Container(),
                          rc.currentConversation.value.isGroup!
                              ? Text(
                                  rc.currentConversation.value
                                              .participants!.length ==
                                          1
                                      ? '1 Member'
                                      : rc.currentConversation.value
                                              .participants!.length
                                              .toString() +
                                          ' Members',
                                  style: const TextStyle(
                                    color: Color(0XFF51545C),
                                    fontSize: 12,
                                  ),
                                )
                              : Container(),
                          rc.currentConversation.value.isGroup!
                              ? const SizedBox(
                                  height: 7,
                                )
                              : Container(),
                          rc.currentConversation.value.isGroup!
                              ? RichText(
                                  text: TextSpan(
                                    text: 'Created ',
                                    style: const TextStyle(
                                      color: Color(0XFF51545C),
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: DateFormat('dd/MM/yyyy')
                                            .format(
                                          rc.currentConversation.value
                                              .createdAt!,
                                        ),
                                        style: const TextStyle(
                                          color: Color(0XFF071439),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ', By ',
                                        style: TextStyle(
                                          color: Color(0XFF51545C),
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: rc.currentConversation
                                            .value.moderatorName,
                                        style: const TextStyle(
                                          color: Color(0XFF071439),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  Container(
                                    height: 42,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                        8,
                                      ),
                                      color: const Color(0XFFEFEFEF),
                                    ),
                                    child: TabBar(
                                      // give the indicator a decoration (color and border radius)
                                      indicator: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                          6.93,
                                        ),
                                        color: green,
                                      ),
                                      labelColor: white,
                                      labelStyle: const TextStyle(
                                        fontSize: 13,
                                      ),
                                      unselectedLabelStyle:
                                          const TextStyle(
                                        fontSize: 13,
                                      ),
                                      unselectedLabelColor:
                                          const Color(0XFF8D9091),
                                      tabs: const [
                                        Tab(
                                          text: 'Photos',
                                        ),
                                        Tab(
                                          text: 'Links',
                                        ),
                                        Tab(
                                          text: 'Docs',
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 160,
                                    child: TabBarView(
                                      children: [
                                        renderPhotos(context),
                                        renderLinks(),
                                        renderDocs(),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showConversationMedia(context);
                                    },
                                    child: Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(
                                              15, 7, 15, 0),
                                      child: const Text(
                                        'See All Media',
                                        style: TextStyle(
                                          color: green,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showEncryptionDetails(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  15, 10, 15, 12),
                              decoration: const BoxDecoration(
                                color: Color(0XFFFBFBFB),
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Color(0XFFF5F7FC),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/shield.svg',
                                        package: 'robin_flutter',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Text(
                                        'Encryption Details',
                                        style: TextStyle(
                                          color: Color(0XFF51545C),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 24,
                                    color: Color(0XFF8D9091),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                15, 10, 15, 12),
                            decoration: const BoxDecoration(
                              color: Color(0XFFFBFBFB),
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Color(0XFFF5F7FC),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/star_blue.svg',
                                      package: 'robin_flutter',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      'Starred Messages - 0',
                                      style: TextStyle(
                                        color: Color(0XFF51545C),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: Color(0XFF8D9091),
                                )
                              ],
                            ),
                          ),
                          rc.currentConversation.value.isGroup!
                              ? const SizedBox(
                                  height: 15,
                                )
                              : Container(),
                          rc.currentConversation.value.isGroup!
                              ? renderParticipants(context)
                              : Container(),
                          const SizedBox(
                            height: 15,
                          ),
                          rc.currentConversation.value.isGroup!
                              ? InkWell(
                                  onTap: () async {
                                    bool successful =
                                        await rc.leaveGroup(rc
                                            .currentConversation
                                            .value
                                            .id!);
                                    if (successful) {
                                      showSuccessMessage(
                                          'Group left successfully');
                                      rc.allConversations.remove(rc
                                          .currentConversation
                                          .value
                                          .id!);
                                      if (rc.currentConversation.value
                                          .archived!) {
                                        rc.renderArchivedConversations();
                                      } else {
                                        rc.renderHomeConversations();
                                      }
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                            15, 10, 15, 12),
                                    decoration: const BoxDecoration(
                                      color: Color(0XFFFFFFFF),
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Color(0XFFF5F7FC),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Text(
                                          'Exit Group',
                                          style: TextStyle(
                                            color: Color(0XFFD53120),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    bool successful =
                                        await rc.deleteConversation();
                                    if (successful) {
                                      showSuccessMessage(
                                          'Deleted successfully');
                                      rc.allConversations.remove(rc
                                          .currentConversation
                                          .value
                                          .id!);
                                      if (rc.currentConversation.value
                                          .archived!) {
                                        rc.renderArchivedConversations();
                                      } else {
                                        rc.renderHomeConversations();
                                      }
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                            15, 10, 15, 12),
                                    decoration: const BoxDecoration(
                                      color: Color(0XFFFFFFFF),
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Color(0XFFF5F7FC),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Text(
                                          'Delete Conversation',
                                          style: TextStyle(
                                            color: Color(0XFFD53120),
                                            fontSize: 16,
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
              ),
      ),
    );
  }
}
