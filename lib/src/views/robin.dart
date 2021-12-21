import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Robin extends StatelessWidget {
  final Map currentUser;
  final String apiKey;
  final Function getUsers;
  final Map keys;

  const Robin({
    Key? key,
    required this.currentUser,
    required this.apiKey,
    required this.getUsers,
    required this.keys,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0XFFFFFFFF),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Color(0XFF535F89),
              fontSize: 16,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/edit.svg',
                    semanticsLabel: 'edit',
                    package: 'robin',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              onPressed: () {
                // _showNewModal();
              },
            )
          ],
          shadowColor: const Color.fromRGBO(0, 104, 255, 0.2),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                  child: Container(
                    height: 50,
                    child: TextFormField(
                      style: const TextStyle(
                        color: Color(0XFF535F89),
                        fontSize: 14,
                      ),
                      // controller: _searchController,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          width: 22,
                          height: 22,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/search.svg',
                              semanticsLabel: 'search',
                              package: 'robin',
                              width: 22,
                              height: 22,
                            ),
                          ),
                        ),
                        hintText: 'Search Messages...',
                        hintStyle: const TextStyle(
                          color: Color(0XFFBBC1D6),
                          fontSize: 16,
                        ),
                        contentPadding: EdgeInsets.all(15.0),
                        filled: true,
                        fillColor: Color(0XFFF4F6F8),
                        // border: textFieldBorder,
                        // focusedBorder: textFieldBorder,
                        // enabledBorder: textFieldBorder,
                      ),
                    ),
                  ),
                ),
                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     InkWell(
                //       onTap: () async {
                //         await Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) =>
                //                 Archived(widget.currentUser, _passConversations),
                //           ),
                //         );
                //         _getConversations();
                //       },
                //       child: Text(
                //         'Archived',
                //         style: TextStyle(
                //           color: Color(0XFF15AE73),
                //           fontSize: 16,
                //         ),
                //       ),
                //     ),
                //     SizedBox(
                //       width: 15,
                //     )
                //   ],
                // ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          centerTitle: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0XFF15AE73),
              ),
            ),
          ),
        ));
  }
}
