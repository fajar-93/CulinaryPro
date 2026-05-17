import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RecipeVideoPlayer extends StatefulWidget {
  final String youtubeId;

  const RecipeVideoPlayer({super.key, required this.youtubeId});

  @override
  State<RecipeVideoPlayer> createState() => _RecipeVideoPlayerState();
}

class _RecipeVideoPlayerState extends State<RecipeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        forceHD: true,
      ),
    );
  }

  @override
  void deactivate() {
    // Pauses video while navigating
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.orange,
        progressColors: const ProgressBarColors(
          playedColor: Colors.orange,
          handleColor: Colors.orangeAccent,
        ),
      ),
      builder: (context, player) {
        return player;
      },
    );
  }
}
