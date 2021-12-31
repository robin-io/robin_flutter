import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatar extends StatelessWidget {
  final bool isGroup;

  const UserAvatar({Key? key, required this.isGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
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
          isGroup ? 'assets/icons/people.svg' : 'assets/icons/person.svg',
          package: 'robin_flutter',
          width: 18,
          height: 18,
        ),
      ),
    );
  }
}
