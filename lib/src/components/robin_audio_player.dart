import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:robin_flutter/src/components/robin_track_shape.dart';
import 'package:robin_flutter/src/utils/constants.dart';

class RobinAudioPlayer extends StatefulWidget {
  final String url;

  const RobinAudioPlayer({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<RobinAudioPlayer> createState() => _RobinAudioPlayerState();
}

class _RobinAudioPlayerState extends State<RobinAudioPlayer> {
  int maxDuration = 100;
  int currentPos = 0;
  String currentPosLabel = "00:00";
  bool isPlaying = false;
  bool audioPlayed = false;

  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      player.onDurationChanged.listen((Duration d) {
        //get the duration of audio
        setState(() {
          maxDuration = d.inMilliseconds;
        });
      });

      player.onAudioPositionChanged.listen((Duration p) {
        currentPos =
            p.inMilliseconds; //get the current position of playing audio

        int sMinutes = Duration(milliseconds: currentPos).inMinutes;
        int sSeconds = Duration(milliseconds: currentPos).inSeconds;

        int rMinutes = sMinutes;
        int rSeconds = sSeconds - (sMinutes * 60);

        setState(() {
          currentPosLabel = "${formatTime(rMinutes)}:${formatTime(rSeconds)}";
        });
      });
      player.onPlayerCompletion.listen((event) {
        setState(() {
          isPlaying = false;
          audioPlayed = false;
          currentPos = 0;
          currentPosLabel = "00:00";
        });
      });
    });
    super.initState();
  }

  String formatTime(int time) {
    if (time.toString().length < 2) {
      return '0$time';
    }
    return time.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 25,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  if (!isPlaying && !audioPlayed) {
                    int result = await player.play(widget.url);
                    if (result == 1) {
                      setState(() {
                        isPlaying = true;
                        audioPlayed = true;
                      });
                    }
                  } else if (audioPlayed && !isPlaying) {
                    int result = await player.resume();
                    if (result == 1) {
                      setState(() {
                        isPlaying = true;
                        audioPlayed = true;
                      });
                    }
                  } else {
                    int result = await player.pause();
                    if (result == 1) {
                      setState(() {
                        isPlaying = false;
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: const Color(0XFF9999BC),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, 3),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackShape: RobinTrackShape(),
                    thumbColor: green,
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    activeTrackColor: const Color(0XFFCCCCCC),
                  ),
                  child: Slider(
                    value: double.parse(currentPos.toString()),
                    min: 0,
                    max: double.parse(maxDuration.toString()),
                    divisions: maxDuration,
                    label: currentPosLabel,
                    onChanged: (double value) async {
                      int seekVal = value.round();
                      int result =
                          await player.seek(Duration(milliseconds: seekVal));
                      if (result == 1) {
                        currentPos = seekVal;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(15, 17),
          child: Text(
            currentPosLabel,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0XFF51545C),
            ),
          ),
        ),
      ],
    );
  }
}
