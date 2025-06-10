import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/views/import.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            Icon(Icons.music_note, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.subhead,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => _buildOptionsSheet(context),
                );
              },
              child: Icon(Icons.more_vert, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading:
                const Icon(Icons.playlist_add, color: AppColors.textPrimary),
            title: const Text('Add to Playlist', style: AppTextStyles.body),
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              showDialog(
                context: context,
                builder: (_) => AddToPlaylistDialog(song: song),
              );
            },
          ),
        ],
      ),
    );
  }
}
