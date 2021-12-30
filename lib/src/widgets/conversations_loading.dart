import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ConversationsLoading extends StatelessWidget {
  const ConversationsLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 15, right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: const Color(0XFFBDBDBD),
              highlightColor: const Color(0XFFF5F5F5),
              enabled: true,
              child: ListView.builder(
                itemBuilder: (_, __) => Container(
                  padding: EdgeInsets.only(top: 7, bottom: 7),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: 6.0,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              height: 6.0,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 80.0,
                              height: 6.0,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                itemCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
