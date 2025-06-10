import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:mu_kiks/views/home/widgets/duration_slider.dart';
import 'package:mu_kiks/core/constants/styles.dart';
import 'package:mu_kiks/core/constants/colors.dart';
import 'package:mu_kiks/views/now_playing/widgets/player_controls.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Now Playing', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          final song = player.currentSong;

          if (song == null) {
            return const Center(
              child: Text(
                'No song is currently playing.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Spacer(),

                // Album Art Placeholder
                Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[800],
                  ),
                  child: const Icon(Icons.music_note,
                      size: 100, color: Colors.white54),
                ),

                const SizedBox(height: 30),

                // Song Title & Artist
                Text(
                  song.title,
                  style: AppTextStyles.headline,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  song.artist,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Duration Slider
                const DurationSlider(),

                const SizedBox(height: 30),

                // Player Controls (shuffle, prev, play/pause, next, repeat)
                const PlayerControls(),

                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}
