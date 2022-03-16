import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../utils/functions.dart';

class RobinSendImage extends StatelessWidget {
  final RobinController rc = Get.find();

  final CarouselController carouselController = CarouselController();
  final TextEditingController captionController = TextEditingController();
  final RxInt currentIndex = 0.obs;

  List<String> captions = [];

  RobinSendImage({Key? key}) : super(key: key) {
    for (int i = 0; i < rc.file.length; i++) {
      captions.add('');
    }
  }

  sendImages(BuildContext context) {
    if (rc.file.isNotEmpty) {
      if (rc.replyView.value) {
        rc.sendReplyAsAttachment(captions: captions);
      } else {
        rc.sendAttachment(captions: captions);
      }
    }
    Navigator.pop(context);
  }

  List<Widget> renderImages() {
    List<Widget> images = [];
    for (int index = 0; index < rc.file.length; index++) {
      var image = rc.file[index];
      images.add(
        Padding(
          padding: const EdgeInsets.only(top: 15.0, right: 7.0),
          child: Image.file(
            File(image.path),
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {});
    return Scaffold(
      backgroundColor: const Color(0XFF04051F),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Obx(
              () => CarouselSlider.builder(
                itemCount: rc.file.length,
                carouselController: carouselController,
                options: CarouselOptions(
                  initialPage: 0,
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  scrollDirection: Axis.horizontal,
                ),
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  currentIndex.value = itemIndex;
                  Future.delayed(const Duration(milliseconds: 200), () {
                    captionController.text = captions[currentIndex.value];
                  });
                  return Image.file(
                    File(rc.file[itemIndex].path),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  );
                },
              ),
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
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            captions.removeAt(currentIndex.value);
                            rc.file.removeAt(currentIndex.value);
                            if (rc.file.isEmpty) {
                              Navigator.pop(context);
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  captions[currentIndex.value] = value;
                                },
                                maxLines: 1,
                                decoration:
                                    textFieldDecoration(radius: 24, style: 1)
                                        .copyWith(
                                  hintText: 'Add Photo Caption...',
                                  fillColor: const Color(0XFFFBFBFB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                sendImages(context);
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: renderImages(),
                        )
                      ],
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
