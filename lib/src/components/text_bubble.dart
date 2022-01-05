import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/models/robin_message.dart';
import 'package:robin_flutter/src/utils/functions.dart';

class TextBubble extends StatelessWidget {
  final RobinMessage message;
  final bool lastInSeries;
  final bool firstInSeries;
  final double maxWidth;

  TextBubble({
    Key? key,
    required this.message,
    required this.lastInSeries,
    required this.firstInSeries,
    required this.maxWidth,
  }) : super(key: key);

  final RobinController rc = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: lastInSeries ? 10 : 5),
      child: InkWell(
        onTap: rc.forwardView.value
            ? () {
                if (!rc.forwardMessages.contains(message.id)) {
                  rc.forwardMessages.add(message.id);
                }
              }
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: message.sentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  minWidth: 55,
                ),
                decoration: BoxDecoration(
                  color: message.sentByMe
                      ? const Color(0XFFD3D7EA)
                      : const Color(0XFFF4F6F8),
                  border: Border.all(
                    width: 1,
                    color: message.sentByMe
                        ? const Color(0XFFD3D7EA)
                        : const Color(0XFFD7E3FD),
                  ),
                  borderRadius: lastInSeries && message.sentByMe
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(0),
                        )
                      : lastInSeries && !message.sentByMe
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(20),
                            )
                          : BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    firstInSeries
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 10, top: 5),
                            child: Text(
                              message.senderName,
                              style: TextStyle(
                                fontSize: 14,
                                color: rc.userColors[message.senderToken] ??
                                    const Color(0XFF7A7A7A),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    message.isAttachment
                        ? Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                fileType(path: message.link) == 'image'
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: (MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.75) -
                                                91,
                                            maxHeight: 211,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) => ImagePreview(
                                              //       widget.messageDetails['content']
                                              //           ['attachment'],
                                              //     ),
                                              //   ),
                                              // );
                                            },
                                            child: Hero(
                                              tag: message.link,
                                              child: CachedNetworkImage(
                                                imageUrl: message.link,
                                                placeholder: (context, url) =>
                                                    const Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 10, 15, 10),
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        Color(0XFF15AE73),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          // if (_fileDownloaded) {
                                          //   OpenFile.open(_filePath);
                                          // } else {
                                          //   if (!_fileDownloading) {
                                          //     _downloadFile(widget.messageDetails['content']
                                          //         ['attachment']);
                                          //   }
                                          // }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color:
                                                        const Color(0XFFECEBEB),
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/fileTypes/${fileType(path: message.link)}.png',
                                                      package: 'robin_flutter',
                                                      fit: BoxFit.fitHeight,
                                                      width: 34,
                                                      height: 40,
                                                    ),
                                                    const SizedBox(
                                                      width: 7,
                                                    ),
                                                    SizedBox(
                                                      height: 40,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            message.senderName,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0XFF000000),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    false
                                                        ? Container()
                                                        : SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child: false
                                                                ? const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2.5,
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation<Color>(
                                                                              green),
                                                                    ),
                                                                  )
                                                                : Center(
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      'assets/icons/export.svg',
                                                                      package:
                                                                          'robin_flutter',
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                    ),
                                                                  ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      dateFormat.format(message.timestamp),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0XFF7A7A7A),
                                      ),
                                    ),
                                    message.sentByMe &&
                                            !rc.currentConversation!.isGroup!
                                        ? SizedBox(
                                            height: 10,
                                            child: SvgPicture.asset(
                                              message.isRead
                                                  ? 'assets/icons/read_receipt.svg'
                                                  : 'assets/icons/unread_receipt.svg',
                                              package: 'robin_flutter',
                                              width: 18,
                                              height: 18,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                getURLPreview(message.text),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            (MediaQuery.of(context).size.width *
                                                    0.75) -
                                                111,
                                      ),
                                      child: formatText(message.text),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          dateFormat.format(message.timestamp),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0XFF7A7A7A),
                                          ),
                                        ),
                                        message.sentByMe &&
                                                !rc.currentConversation!
                                                    .isGroup!
                                            ? SizedBox(
                                                height: 10,
                                                child: SvgPicture.asset(
                                                  message.isRead
                                                      ? 'assets/icons/read_receipt.svg'
                                                      : 'assets/icons/unread_receipt.svg',
                                                  package: 'robin_flutter',
                                                  width: 18,
                                                  height: 18,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
