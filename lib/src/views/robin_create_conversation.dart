import 'package:flutter/material.dart';
import 'package:robin_flutter/src/controllers/robin_controller.dart';
import 'package:robin_flutter/src/models/robin_conversation.dart';
import 'package:robin_flutter/src/utils/functions.dart';
import 'package:robin_flutter/src/views/robin_archived.dart';
import 'package:robin_flutter/src/widgets/conversations_loading.dart';
import 'package:robin_flutter/src/widgets/empty_conversation.dart';
import 'package:robin_flutter/src/widgets/conversation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robin_flutter/src/models/robin_user.dart';
import 'package:robin_flutter/src/models/robin_keys.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:get/get.dart';

class RobinCreateConversation extends StatelessWidget {
  final RobinController rc = Get.find();

  RobinCreateConversation({Key? key}) : super(key: key){
    rc.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        closeButton(context),
        Container(
          height: MediaQuery.of(context).size.height - 110,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    false
                        ? Text(
                            'Done',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0X0015AE73),
                            ),
                          )
                        : Container(),
                    Container(
                      width: 45,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0XFFF4F6F8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    false
                        ? InkWell(
                            onTap: () async {},
                            child: Text(
                              'Done',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0XFF15AE73),
                              ),
                            ),
                          )
                        : Container(height: 19),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: TextFormField(
                  style: const TextStyle(
                    color: Color(0XFF535F89),
                    fontSize: 14,
                  ),
                  controller: rc.homeSearchController,
                  decoration: textFieldDecoration.copyWith(
                    prefixIcon: SizedBox(
                      width: 22,
                      height: 22,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/search.svg',
                          semanticsLabel: 'search',
                          package: 'robin_flutter',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                    hintText: 'Search People...',
                  ),
                ),
              ),
              true
                  ? InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: Color(0XFFF4F6F8),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0XFFF4F6F8),
                                  border: Border.all(
                                    width: 1,
                                    style: BorderStyle.solid,
                                    color: const Color(0XFFCADAF8),
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/people.svg',
                                    package: 'robin_flutter',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Create A New Group',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SizedBox(height: 20),
              false
                  ? Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0XFF15AE73)),
                      ),
                    )
                  : false
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 35),
                            Image.asset(
                              'assets/images/empty.png',
                              package: 'robin',
                            ),
                            SizedBox(height: 25),
                            Text(
                              'Nobody Here Yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0XFF535F89),
                              ),
                            ),
                            SizedBox(height: 13),
                          ],
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [SizedBox(height: 20)],
                            ),
                          ),
                        )
            ],
          ),
        ),
      ],
    );
  }
}
