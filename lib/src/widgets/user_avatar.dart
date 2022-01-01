import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatar extends StatelessWidget {
  final bool isGroup;
  final double? size;

  const UserAvatar({
    Key? key,
    required this.isGroup,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 45,
      height: size ?? 45,
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
          width: (size ?? 45) / 2.5,
          height: (size ?? 45) / 2.5,
        ),
      ),
    );
  }
}
