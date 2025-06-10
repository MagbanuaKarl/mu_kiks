import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/views/import.dart';
import 'package:mu_kiks/providers/import.dart';

class HomeScreen extends StatelessWidget {
  final List<Song> songs;

  const HomeScreen({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          AppStrings.appName,
          style: AppTextStyles.headline,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaylistScreen()),
              );
            },
          ),
        ],
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                AppStrings.noSongsFound,
                style: AppTextStyles.body,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return GestureDetector(
                  onTap: () async {
                    final playerProvider = context.read<PlayerProvider>();
                    await playerProvider.setPlaylist(songs, startIndex: index);

                    // Explicitly start playback
                    playerProvider.play();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NowPlayingScreen()),
                    );
                  },
                  child: SongTile(song: song),
                );
              },
            ),
    );
  }
}
