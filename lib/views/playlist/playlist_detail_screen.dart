import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/playlist_model.dart';
import 'package:mu_kiks/providers/playlist_provider.dart';
import 'package:mu_kiks/core/import.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final playlist = context.watch<PlaylistProvider>().playlists.firstWhere(
        (p) => p.id == playlistId,
        orElse: () => Playlist.create(name: 'Unknown'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          playlist.name,
          style: AppTextStyles.headline,
        ),
      ),
      body: playlist.songs.isEmpty
          ? const Center(
              child:
                  Text('No songs in this playlist', style: AppTextStyles.body),
            )
          : ListView.builder(
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                return ListTile(
                  title: Text(song.title, style: AppTextStyles.body),
                  subtitle: Text(song.artist, style: AppTextStyles.caption),
                  onTap: () {
                    // Optional: play this song
                  },
                );
              },
            ),
    );
  }
}
