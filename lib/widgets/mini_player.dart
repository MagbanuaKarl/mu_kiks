import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:mu_kiks/views/now_playing/now_playing_screen.dart';
import 'package:mu_kiks/core/import.dart';

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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.music_note,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentSong.title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentSong.artist,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                player.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                player.isPlaying ? player.pause() : player.play();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: AppColors.textPrimary,
              ),
              onPressed: player.next,
            ),
          ],
        ),
      ),
    );
  }
}
