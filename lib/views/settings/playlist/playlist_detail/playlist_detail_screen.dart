import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/playlist_model.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:mu_kiks/providers/playlist_provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/views/import.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final playlist = context.watch<PlaylistProvider>().playlists.firstWhere(
          (p) => p.id == playlistId,
          orElse: () => Playlist.create(name: 'Unknown'),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlaylistDetailScreenAppBar(
              onBack: () => Navigator.pop(context),
              onRename: () {
                Navigator.pop(context);
                showRenamePlaylistDialog(
                  context: context,
                  playlist: playlist,
                  onRename: (newName) {
                    context
                        .read<PlaylistProvider>()
                        .renamePlaylist(playlist.id, newName);
                  },
                );
              },
              onDelete: () {
                Navigator.pop(context);
                showConfirmDeleteDialog(
                  context: context,
                  playlistName: playlist.name,
                  onConfirm: () {
                    context
                        .read<PlaylistProvider>()
                        .deletePlaylist(playlist.id);
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                playlist.name,
                style: AppTextStyles.headline,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: playlist.songs.isEmpty
                  ? const Center(
                      child: Text('No songs in this playlist',
                          style: AppTextStyles.body),
                    )
                  : ListView.builder(
                      itemCount: playlist.songs.length,
                      itemBuilder: (context, index) {
                        final Song song = playlist.songs[index];
                        return PlaylistSongTile(
                          song: song,
                          playlist: playlist.songs,
                          number: index + 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
