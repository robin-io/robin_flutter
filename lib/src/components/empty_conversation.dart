import 'package:flutter/material.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';

class EmptyConversation extends StatelessWidget {
  const EmptyConversation({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 230,
              ),
              child: Image.asset(
                'assets/images/empty.png',
                package: 'robin_flutter',
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 16,
                color: Color(0XFF535F89),
              ),
            ),
            const SizedBox(height: 13),
            InkWell(
              onTap: () {
                showCreateConversation(context);
              },
              child: const Text(
                'Start a chat',
                style: TextStyle(
                  fontSize: 16,
                  color: green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}