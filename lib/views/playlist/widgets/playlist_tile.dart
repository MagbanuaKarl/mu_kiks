import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/core/constants/colors.dart';
import 'package:mu_kiks/core/constants/styles.dart';
import 'package:mu_kiks/views/import.dart';
import 'package:mu_kiks/providers/import.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
    this.onRename,
    this.onDelete,
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
      onTap: onTap, // <-- ADD THIS LINE
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
        onSelected: (value) {
          if (value == 'rename') {
            showRenamePlaylistDialog(
              context: context,
              playlist: playlist,
              onRename: (newName) {
                context
                    .read<PlaylistProvider>()
                    .renamePlaylist(playlist.id, newName);
              },
            );
          } else if (value == 'delete') {
            showConfirmDeleteDialog(
              context: context,
              playlistName: playlist.name,
              onConfirm: () {
                context.read<PlaylistProvider>().deletePlaylist(playlist.id);
              },
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'rename',
            child: Text('Rename'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
