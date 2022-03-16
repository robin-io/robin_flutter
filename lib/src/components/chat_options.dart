import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:robin_flutter/src/utils/constants.dart';
import 'package:robin_flutter/src/utils/functions.dart';

@immutable
class ChatOptions extends StatefulWidget {
  const ChatOptions({
    Key? key,
  }) : super(key: key);

  @override
  _ChatOptionsState createState() => _ChatOptionsState();
}

class _ChatOptionsState extends State<ChatOptions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        _buildTapToCloseFab(),
        ..._buildExpandingActionButtons(),
        _buildTapToOpenFab(),
      ],
    );
  }

  Widget _buildTapToCloseFab() {
    return InkWell(
      onTap: _toggle,
      child: Container(
        width: 52.0,
        height: 52.0,
        decoration: const BoxDecoration(
          color: Color(0XFFF5F7FC),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.close,
            color: Color(0XFF51545C),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[
      _ExpandingActionButton(
        progress: _expandAnimation,
      ),
    ];
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: InkWell(
            onTap: _toggle,
            child: Container(
              width: 52.0,
              height: 52.0,
              decoration: const BoxDecoration(
                color: Color(0XFFF5F7FC),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: green,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    Key? key,
    required this.progress,
  }) : super(key: key);

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          1.571,
          progress.value * 75,
        );
        return Positioned(
          left: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: child!,
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: Container(
          width: 192,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: white,
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  getMedia(context, source: 'camera');
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Camera',
                        style: TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: SvgPicture.asset(
                          'assets/icons/camera.svg',
                          package: 'robin_flutter',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(
                height: 2,
              ),
              InkWell(
                onTap: () {
                  getMedia(context, source: 'gallery');
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Photos & Videos',
                        style: TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: SvgPicture.asset(
                          'assets/icons/image.svg',
                          package: 'robin_flutter',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(
                height: 2,
              ),
              InkWell(
                onTap: () {
                  getDocument();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Document',
                        style: TextStyle(
                          color: Color(0XFF51545C),
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: SvgPicture.asset(
                          'assets/icons/document.svg',
                          package: 'robin_flutter',
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
