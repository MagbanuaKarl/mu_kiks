import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:mu_kiks/views/import.dart'; // for NowPlayingScreen

class PlaylistSongTile extends StatelessWidget {
  final Song song;
  final List<Song> playlist;
  final int? number;

  const PlaylistSongTile({
    super.key,
    required this.song,
    required this.playlist,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final playerProvider = context.read<PlayerProvider>();
        await playerProvider.playFromPlaylist(playlist, song);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NowPlayingScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (number != null)
              Text(
                '$number',
                style: AppTextStyles.subhead.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Icon(Icons.music_note, color: AppColors.accent),
            if (number != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 1,
                height: 24,
                color: AppColors.textSecondary.withOpacity(0.3),
              )
            else
              const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.subhead.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
