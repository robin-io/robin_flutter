import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/components/message-group/text_bubble.dart';
import 'package:robin_flutter/src/components/user_avatar.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/components/conversations_loading.dart';
import 'package:robin_flutter/src/components/empty_conversation.dart';
import 'package:robin_flutter/src/components/conversation.dart';
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
      for (Map doc in rc.currentConversationInfo['photos']) {
        RobinMessage message = RobinMessage.fromJson(doc);
        docs.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreview(
                    message.link,
                  ),
                ),
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

  Widget renderParticipants() {
    List<Widget> participants = [];
    for (Map participant in rc.currentConversation!.participants!) {
      bool isCurrentUser =
          participant['user_token'] == rc.currentUser!.robinToken;
      participants.add(
        Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(width: 1, color: Color(0XFFF1F3F8)))),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            children: [
              const UserAvatar(
                isGroup: false,
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
                  ],
                ),
              ),
            ],
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
    return SizedBox(
      height: MediaQuery.of(context).size.height - 45,
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, 15),
            child: Container(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.93,
              decoration: const BoxDecoration(
                color: Color(0XFFEBF3FE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(
                () => Container(
                  height: MediaQuery.of(context).size.height - 75,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: rc.chatViewLoading.value ||
                          rc.gettingConversationInfo.value
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
                                      rc.currentConversation!.isGroup!
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
                                      isGroup: rc.currentConversation!.isGroup!,
                                      conversationIcon: rc.currentConversation!
                                          .conversationIcon,
                                      size: 75,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      rc.currentConversation!.name!,
                                      style: const TextStyle(
                                        color: black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    rc.currentConversation!.isGroup!
                                        ? const SizedBox(
                                            height: 7,
                                          )
                                        : Container(),
                                    rc.currentConversation!.isGroup!
                                        ? Text(
                                            rc.currentConversation!
                                                        .participants!.length ==
                                                    1
                                                ? '1 Member'
                                                : rc.currentConversation!
                                                        .participants!.length
                                                        .toString() +
                                                    ' Members',
                                            style: const TextStyle(
                                              color: Color(0XFF51545C),
                                              fontSize: 12,
                                            ),
                                          )
                                        : Container(),
                                    rc.currentConversation!.isGroup!
                                        ? const SizedBox(
                                            height: 7,
                                          )
                                        : Container(),
                                    rc.currentConversation!.isGroup!
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
                                                    rc.currentConversation!
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
                                                      ?.moderatorName,
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
                                              height: 215,
                                              child: TabBarView(
                                                children: [
                                                  renderPhotos(context),
                                                  renderLinks(),
                                                  renderDocs(),
                                                ],
                                              ),
                                            ),
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
                                    rc.currentConversation!.isGroup!
                                        ? const SizedBox(
                                            height: 15,
                                          )
                                        : Container(),
                                    rc.currentConversation!.isGroup!
                                        ? Container(
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                        color:
                                                            Color(0XFF51545C),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    rc.currentConversation!.isGroup!
                                        ? renderParticipants()
                                        : Container(),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    rc.currentConversation!.isGroup!
                                        ? InkWell(
                                            onTap: () async {
                                              bool successful =
                                                  await rc.leaveGroup(rc
                                                      .currentConversation!
                                                      .id!);
                                              if (successful) {
                                                showSuccessMessage(
                                                    'Group left successfully');
                                                rc.allConversations.remove(rc
                                                    .currentConversation!.id!);
                                                if (rc.currentConversation!
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
                                                    .currentConversation!.id!);
                                                if (rc.currentConversation!
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
