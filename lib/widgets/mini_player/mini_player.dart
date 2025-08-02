import 'package:flutter/material.dart';
import 'package:mu_kiks/widgets/mini_player/player_container.dart';
import 'package:mu_kiks/widgets/mini_player/protruding_icon.dart';
import 'package:mu_kiks/widgets/mini_player/song_marquee.dart';
import 'package:mu_kiks/widgets/mini_player/mini_player_controls.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:mu_kiks/views/import.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final Song? currentSong = player.currentSong;

    if (currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      },
      child: PlayerContainer(
        protrudingIcon: const ProtrudingIcon(),
        songMarquee: SongMarquee(title: currentSong.title),
        controls: const MiniPlayerControls(),
      ),
    );
  }
}
