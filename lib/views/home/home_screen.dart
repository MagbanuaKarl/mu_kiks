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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: songs.isEmpty
              ? const Center(
                  child: Text(
                    AppStrings.noSongsFound,
                    style: AppTextStyles.body,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeSearchBar(),
                    const SizedBox(height: 16),
                    const QuickActionsRow(),
                    const SizedBox(height: 16),
                    const PlaybackControlsRow(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return GestureDetector(
                            onTap: () async {
                              final playerProvider =
                                  context.read<PlayerProvider>();
                              await playerProvider.setPlaylist(songs,
                                  startIndex: index);

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
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
