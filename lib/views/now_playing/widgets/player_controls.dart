import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/import.dart';
import 'package:mu_kiks/core/import.dart';

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
          onPressed: player.toggleShuffle,
        ),

        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 36,
          onPressed: player.skipPrevious,
        ),

        // Play / Pause
        IconButton(
          icon: Icon(
            player.isPlaying ? Icons.pause_circle : Icons.play_circle,
          ),
          iconSize: 48,
          color: AppColors.primary,
          onPressed: player.togglePlayPause,
        ),

        // Next
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 36,
          onPressed: player.skipNext,
        ),

        // Repeat (cycles off → all → one → off)
        IconButton(
          icon: Icon(
            player.isLoopingOne ? Icons.repeat_one : Icons.repeat,
            color: (player.isLooping || player.isLoopingOne)
                ? AppColors.primary
                : Colors.grey,
          ),
          onPressed: player.toggleLoop,
        ),
      ],
    );
  }
}
