import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:robin_flutter/src/utils/functions.dart';

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
        GestureDetector(
          onTap: () {
            carouselController.jumpToPage(index);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, right: 7.0),
            child: Container(
              padding: const EdgeInsets.all(2),
              color: currentIndex.value == index
                  ? Colors.white
                  : Colors.transparent,
              child: Image.file(
                File(image.path),
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
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
                    onPageChanged: (index, reason) {
                      currentIndex.value = index;
                      captionController.text = captions[currentIndex.value];
                      captionController.selection = TextSelection.fromPosition(
                          TextPosition(offset: captionController.text.length));
                    }),
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
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
                            int delete = currentIndex.value;
                            if (rc.file.length != 1 &&
                                currentIndex.value == rc.file.length - 1) {
                              carouselController
                                  .jumpToPage(currentIndex.value - 1);
                            }
                            captions.removeAt(delete);
                            rc.file.removeAt(delete);
                            if (rc.file.isEmpty) {
                              Navigator.pop(context);
                            } else {
                              captionController.text =
                                  captions[currentIndex.value];
                              captionController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: captionController.text.length));
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: renderImages(),
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
        ),
      ),
    );
  }
}
