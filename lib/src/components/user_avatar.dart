import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? conversationIcon;
  final double? size;

  const UserAvatar({
    Key? key,
    required this.name,
    this.conversationIcon,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String initials = '';
    int count = 0;
    for (String initial in name.split(' ')) {
      if (count < 2) {
        if (initial.isNotEmpty) {
          initials += initial[0].toUpperCase();
          count += 1;
        }
      } else {
        break;
      }
    }
    return conversationIcon == null || conversationIcon!.isEmpty
        ? Container(
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
              child: Text(
                initials,
                maxLines: 1,
                style: TextStyle(
                  fontSize: (size ?? 45) / 2.81,
                  fontWeight: FontWeight.w500,
                  color: const Color(0XFF9999BC),
                ),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0XFFF4F6F8),
              border: Border.all(
                width: 1,
                style: BorderStyle.solid,
                color: const Color(0XFFCADAF8),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular((size ?? 45) / 2),
              child: CachedNetworkImage(
                imageUrl: conversationIcon!,
                fit: BoxFit.cover,
                width: size ?? 45,
                height: size ?? 45,
                placeholder: (context, url) {
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
                      child: Text(
                        initials,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: (size ?? 45) / 2.81,
                          fontWeight: FontWeight.w500,
                          color: const Color(0XFF9999BC),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }
}
