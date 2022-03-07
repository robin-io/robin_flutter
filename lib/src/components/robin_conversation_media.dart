import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:carousel_slider/carousel_slider.dart';

class RobinConversationMedia extends StatelessWidget {
  final RobinController rc = Get.find();

  RobinConversationMedia({Key? key}) : super(key: key);

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
                                  return Container(
                                    child: CachedNetworkImage(
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
                                    ),
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
              padding: const EdgeInsets.all(3.0),
              child: Hero(
                tag: message.link,
                child: CachedNetworkImage(
                  imageUrl: message.link,
                  width: 80,
                  height: 63,
                  fit: BoxFit.fitWidth,
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
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
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
                                ? 'Group Media'
                                : 'Chat Media',
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
                                    height: MediaQuery.of(context)
                                            .size
                                            .height -
                                        220,
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
