import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/providers/import.dart';
import 'package:mu_kiks/views/import.dart';
import 'package:mu_kiks/core/import.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

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
              return PlaylistTile(playlist: playlist);
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
