import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/providers/import.dart';
import 'package:mu_kiks/views/import.dart';
import 'package:mu_kiks/core/import.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  void _showOptionsMenu(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.textPrimary),
              title: const Text('Rename', style: AppTextStyles.body),
              onTap: () {
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
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete', style: AppTextStyles.body),
              onTap: () {
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Playlists',
          style: AppTextStyles.headline,
        ),
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, _) {
          final playlists = playlistProvider.playlists;

          if (playlists.isEmpty) {
            return const Center(
              child: Text(
                'No playlists found.',
                style: AppTextStyles.body,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return GestureDetector(
                onLongPress: () => _showOptionsMenu(context, playlist),
                child: PlaylistTile(
                  playlist: playlist,
                  onTap: () {
                    // TODO: Navigate to playlist detail page if needed
                  },
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddToPlaylistDialog(isCreatingNew: true),
          );
        },
      ),
    );
  }
}
