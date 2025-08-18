import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/providers/player_provider.dart';

class MiniPlayerControls extends StatelessWidget {
  const MiniPlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    // Determine loop icon based on current repeat mode
    IconData loopIcon;
    Color loopColor = AppColors.textPrimary;

    if (player.isLoopingOne) {
      loopIcon = Icons.repeat_one;
      loopColor = AppColors.primary;
    } else if (player.isLooping) {
      loopIcon = Icons.repeat;
      loopColor = AppColors.primary;
    } else {
      loopIcon = Icons.repeat;
      loopColor = AppColors.textSecondary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.skip_previous, color: AppColors.textPrimary),
          onPressed: player.skipPrevious,
        ),

        // Play / Pause with progress indicator
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: player.progress.clamp(0.0, 1.0),
                strokeWidth: 2.5,
                backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: Icon(
                player.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                player.isPlaying ? player.pause() : player.play();
              },
            ),
          ],
        ),

        const SizedBox(width: 8),

        // Next button
        IconButton(
          icon: const Icon(Icons.skip_next, color: AppColors.textPrimary),
          onPressed: player.skipNext,
        ),

        const SizedBox(width: 4),

        // Loop / Repeat button
        IconButton(
          icon: Icon(loopIcon, color: loopColor),
          onPressed: () => player.toggleLoop(),
          tooltip: 'Repeat',
        ),
      ],
    );
  }
}
