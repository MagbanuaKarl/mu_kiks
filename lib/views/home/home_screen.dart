import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/views/import.dart';
import 'package:mu_kiks/providers/import.dart';

class HomeScreen extends StatefulWidget {
  final List<Song> songs;
  final VoidCallback? onScanRequested; // ✅ Added

  const HomeScreen({
    super.key,
    required this.songs,
    this.onScanRequested, // ✅ Added
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Song> filteredSongs;

  @override
  void initState() {
    super.initState();
    filteredSongs = widget.songs;
  }

  void _filterSongs(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredSongs = widget.songs.where((song) {
        final titleMatch = song.title.toLowerCase().contains(lowerQuery);
        final artistMatch = (song.artist).toLowerCase().contains(lowerQuery);
        return titleMatch || artistMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeSearchBar(
                onSearch: _filterSongs,
                onScanRequested: widget.onScanRequested, // ✅ Pass down
              ),
              const SizedBox(height: 16),
              const QuickActionsRow(),
              const SizedBox(height: 16),
              const PlaybackControlsRow(),
              const SizedBox(height: 16),
              Expanded(
                child: filteredSongs.isEmpty
                    ? const Center(
                        child: Text(
                          AppStrings.noSongsFound,
                          style: AppTextStyles.body,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          final song = filteredSongs[index];
                          return GestureDetector(
                            onTap: () async {
                              final playerProvider =
                                  context.read<PlayerProvider>();
                              await playerProvider.setPlaylist(
                                filteredSongs,
                                startIndex: index,
                              );
                              playerProvider.play();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NowPlayingScreen(),
                                ),
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
