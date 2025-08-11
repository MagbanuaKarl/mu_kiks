import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/views/import.dart';
import 'package:mu_kiks/providers/import.dart';

class HomeScreen extends StatefulWidget {
  final List<Song> songs;
  final Future<void> Function()? onScanRequested; // ✅ Changed to async-friendly

  const HomeScreen({
    super.key,
    required this.songs,
    this.onScanRequested,
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
        final artistMatch = song.artist.toLowerCase().contains(lowerQuery);
        return titleMatch || artistMatch;
      }).toList();
    });
  }

  void _sortSongs(String sortType) {
    setState(() {
      if (sortType == "time") {
        filteredSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      } else if (sortType == "name") {
        filteredSongs.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      } else if (sortType == "timesPlayed") {
        filteredSongs.sort((a, b) => b.playCount.compareTo(a.playCount));
      }
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
                onScanRequested: widget.onScanRequested,
              ),
              const SizedBox(height: 16),
              QuickActionsRow(),
              const SizedBox(height: 16),
              PlaybackControlsRow(
                onSortSelected: _sortSongs,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredSongs.isEmpty
                    ? const Center(
                        child: Text(
                          AppStrings.noSongsFound,
                          style: AppTextStyles.body,
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: Colors.grey[900],
                        onRefresh: () async {
                          if (widget.onScanRequested != null) {
                            await widget.onScanRequested!();
                          }
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
