import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robin_flutter/src/components/robin_track_shape.dart';
import 'package:robin_flutter/src/utils/constants.dart';

class RobinAudioPlayer extends StatefulWidget {
  final String url;
  final String conversationId;

  const RobinAudioPlayer({
    Key? key,
    required this.url,
    required this.conversationId,
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
  bool canPlay = false;
  bool downloading = false;
  String filePath = '';

  AudioPlayer player = AudioPlayer(playerId: 'robin_voice_note_player_id');

  getAudioFile() async {
    canPlay = false;
    downloading = true;
    String fileName = '${widget.conversationId}${widget.url.split('/').last}';
    var dir = await getTemporaryDirectory();
    File file = File(dir.path + '/$fileName');
    if (file.existsSync()) {
      filePath = file.path;
      setState(() {
        canPlay = true;
        downloading = false;
      });
    } else {
      try {
        http.Client client = http.Client();
        var req = await client.get(Uri.parse(widget.url));
        var bytes = req.bodyBytes;
        var dir = await getTemporaryDirectory();
        File file = File(dir.path + '/$fileName');
        await file.writeAsBytes(bytes);
        filePath = file.path;
        setState(() {
          canPlay = true;
          downloading = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          canPlay = false;
          downloading = false;
        });
      }
    }
  }

  @override
  void initState() {
    getAudioFile();
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
              !canPlay
                  ? Transform.translate(
                offset: const Offset(0, 2.5),
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 18,
                  ),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(green),
                    ),
                  ),
                ),
              )
                  : !downloading && !canPlay
                  ? Transform.translate(
                      offset: const Offset(0, 2.5),
                      child: GestureDetector(
                        onTap: () {
                          getAudioFile();
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 18,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/export.svg',
                              package: 'robin_flutter',
                              width: 20,
                              height: 20,
                            )),
                      ),
                    )
                  :  GestureDetector(
                          onTap: () async {
                            if (!isPlaying && !audioPlayed) {
                              await player.stop();
                              int result =
                                  await player.play(filePath, isLocal: true);
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
                            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 32,
                              color: const Color(0XFF9999BC),
                            ),
                          ),
                        ),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, 3),
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
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(45, 17),
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
