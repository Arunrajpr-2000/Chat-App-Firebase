import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class NetworkAudioPlayer extends StatefulWidget {
  const NetworkAudioPlayer({
    Key? key,
    required this.audioUrl,
  }) : super(key: key);

  final String audioUrl;

  @override
  _NetworkAudioPlayerState createState() => _NetworkAudioPlayerState();
}

class _NetworkAudioPlayerState extends State<NetworkAudioPlayer> {
  late final AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setSourceUrl(widget.audioUrl);

    _audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        _position = duration;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      // Reset position to the beginning when playback completes
      setState(() {
        _position = Duration.zero;
        isPlaying = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
mainAxisSize: MainAxisSize.min,
        children: [
        IconButton(
          onPressed: () {
            if (isPlaying) {
              _audioPlayer.pause();
            } else {
              _audioPlayer.play(UrlSource( widget.audioUrl));
            }
            setState(() {
              isPlaying = !isPlaying;
            });
          },
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 30,
            color: Colors.blue,
          ),
        ) ,
        Slider(
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
          onChanged: (value) {
            final duration = _duration;
            if (duration == null) {

              return;
            }
            final position = value * duration.inMilliseconds;
            _audioPlayer.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
              _duration != null &&
              _position!.inMilliseconds > 0 &&
              _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),
      ],)

    );
  }
}
