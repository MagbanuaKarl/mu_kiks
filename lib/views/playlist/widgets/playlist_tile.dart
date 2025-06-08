import 'package:flutter/material.dart';
import 'package:mu_kiks/models/playlist_model.dart';
import 'package:mu_kiks/core/constants/colors.dart';
import 'package:mu_kiks/core/constants/styles.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;

  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: AppColors.surface,
      leading: Icon(Icons.playlist_play, color: AppColors.accent),
      title: Text(
        playlist.name,
        style: AppTextStyles.subhead,
      ),
      subtitle: Text(
        '${playlist.songs.length} song(s)',
        style: AppTextStyles.caption,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
      onTap: onTap ?? () {},
    );
  }
}
