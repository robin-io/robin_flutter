import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class RobinSendMedia extends StatefulWidget {
  const RobinSendMedia({Key? key, this.isVideo}) : super(key: key);

  final bool? isVideo;

  @override
  State<RobinSendMedia> createState() => _RobinSendMediaState();
}

class _RobinSendMediaState extends State<RobinSendMedia> {
  final RobinController rc = Get.find();

  final CarouselController carouselController = CarouselController();

  final TextEditingController captionController = TextEditingController();

  int currentIndex = 0;

  bool thumbnailsLoaded = false;

  List<Widget> allMedia = [];

  List<VideoPlayerController> videoControllers = [];

  List<String> captions = [];

  @override
  void initState() {
    super.initState();
    renderMedia();
    for (int i = 0; i < rc.file.length; i++) {
      captions.add('');
    }
  }

  sendMedia(BuildContext context) {
    if (rc.file.isNotEmpty) {
      if (rc.replyView.value) {
        rc.sendReplyAsAttachment(captions: captions);
      } else {
        rc.sendAttachment(captions: captions);
      }
    }
    Navigator.pop(context);
  }

  void renderMedia() async {
    allMedia = [];
    for (int index = 0; index < rc.file.length; index++) {
      String mediaPath = rc.file[index].path;
      if (fileType(path: mediaPath) == 'video') {
        videoControllers.add(VideoPlayerController.file(
          File(
            mediaPath,
          ),
        )..initialize());
        final uint8list = await VideoThumbnail.thumbnailData(
          video: mediaPath,
          quality: 25,
        );
        allMedia.add(
          GestureDetector(
            onTap: () {
              carouselController.jumpToPage(index);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, right: 7.0),
              child: Container(
                padding: const EdgeInsets.all(2),
                color:
                    currentIndex == index ? Colors.white : Colors.transparent,
                child: Image.memory(
                  uint8list!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      } else {
        allMedia.add(
          GestureDetector(
            onTap: () {
              carouselController.jumpToPage(index);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, right: 7.0),
              child: Container(
                padding: const EdgeInsets.all(2),
                color:
                    currentIndex == index ? Colors.white : Colors.transparent,
                child: Image.file(
                  File(mediaPath),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }
    }
    setState(() {
      thumbnailsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF04051F),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: thumbnailsLoaded
            ? Stack(
                children: [
                  widget.isVideo != null && widget.isVideo!
                      ? GestureDetector(
                          onTap: () {
                            if (videoControllers[currentIndex]
                                .value
                                .isPlaying) {
                              setState(() {
                                videoControllers[currentIndex].pause();
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              Center(
                                child: AspectRatio(
                                  aspectRatio: videoControllers[currentIndex]
                                      .value
                                      .aspectRatio,
                                  child: VideoPlayer(
                                    videoControllers[currentIndex],
                                  ),
                                ),
                              ),
                              videoControllers[currentIndex].value.isPlaying
                                  ? Container()
                                  : Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            videoControllers[currentIndex].play();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[400],
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            size: 50,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        )
                      : CarouselSlider.builder(
                          itemCount: rc.file.length,
                          carouselController: carouselController,
                          options: CarouselOptions(
                              initialPage: 0,
                              height: MediaQuery.of(context).size.height,
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              autoPlay: false,
                              scrollDirection: Axis.horizontal,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                  renderMedia();
                                  captionController.text =
                                      captions[currentIndex];
                                  captionController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: captionController.text.length),
                                  );
                                });
                              }),
                          itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) {
                            if (fileType(path: rc.file[itemIndex].path) ==
                                'video') {
                              return AspectRatio(
                                aspectRatio: videoControllers[itemIndex]
                                    .value
                                    .aspectRatio,
                                child: VideoPlayer(
                                  videoControllers[itemIndex],
                                ),
                              );
                            }
                            return Image.file(
                              File(rc.file[itemIndex].path),
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fitWidth,
                            );
                          },
                        ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  rc.file.value = [];
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  int delete = currentIndex;
                                  if (rc.file.length != 1 &&
                                      currentIndex == rc.file.length - 1) {
                                    carouselController
                                        .jumpToPage(currentIndex - 1);
                                  }
                                  captions.removeAt(delete);
                                  rc.file.removeAt(delete);
                                  if (rc.file.isEmpty) {
                                    Navigator.pop(context);
                                  } else {
                                    captionController.text =
                                        captions[currentIndex];
                                    captionController.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset:
                                                captionController.text.length));
                                  }
                                },
                                icon: SvgPicture.asset(
                                  'assets/icons/delete_outline.svg',
                                  package: 'robin_flutter',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      style: const TextStyle(
                                        color: Color(0XFF333F69),
                                        fontSize: 15,
                                      ),
                                      controller: captionController,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onChanged: (value) {
                                        captions[currentIndex] = value;
                                      },
                                      maxLines: 1,
                                      decoration: textFieldDecoration(
                                              radius: 24, style: 1)
                                          .copyWith(
                                        hintText: 'Add A Caption...',
                                        fillColor: const Color(0XFFFBFBFB),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      sendMedia(context);
                                    },
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: const BoxDecoration(
                                        color: Color(0XFF15AE73),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
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
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: thumbnailsLoaded
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        // children: renderMedia(),
                                        children: allMedia,
                                      )
                                    : Center(
                                        child: Text(
                                          thumbnailsLoaded.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
