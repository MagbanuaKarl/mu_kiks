import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/providers/player_provider.dart';

class MiniPlayerControls extends StatelessWidget {
  const MiniPlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<double>(
          stream: player.progressStream,
          initialData: 0.0,
          builder: (context, snapshot) {
            final progress = snapshot.data ?? 0.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
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
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: AppColors.textPrimary,
          ),
          onPressed: player.next,
        ),
      ],
    );
  }
}
