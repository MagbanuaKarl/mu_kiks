import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:mu_kiks/core/constants/colors.dart';
// import 'package:mu_kiks/core/constants/styles.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: player.isShuffling ? AppColors.primary : Colors.grey,
          ),
          onPressed: () => player.toggleShuffle(),
        ),

        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 36,
          onPressed: () => player.previous(),
        ),

        // Play / Pause
        IconButton(
          icon: Icon(
            player.isPlaying ? Icons.pause_circle : Icons.play_circle,
          ),
          iconSize: 48,
          color: AppColors.primary,
          onPressed: () {
            player.isPlaying ? player.pause() : player.play();
          },
        ),

        // Next
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 36,
          onPressed: () => player.next(),
        ),

        // Repeat
        IconButton(
          icon: Icon(
            player.isLoopingOne
                ? Icons.repeat_one
                : player.isLooping
                    ? Icons.repeat
                    : Icons.repeat, // same icon but greyed
            color: player.isLooping || player.isLoopingOne
                ? AppColors.primary
                : Colors.grey,
          ),
          onPressed: () {
            if (player.isLoopingOne) {
              player.toggleLoopOne(); // turn off
            } else if (player.isLooping) {
              player.toggleLoopOne(); // switch to repeat one
            } else {
              player.toggleLoopPlaylist(); // turn on repeat all
            }
          },
        ),
      ],
    );
  }
}
