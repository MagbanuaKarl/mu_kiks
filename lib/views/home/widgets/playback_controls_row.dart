import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/providers/player_provider.dart';

class PlaybackControlsRow extends StatelessWidget {
  final void Function(String sortType) onSortSelected;
  final List<Song> allSongs;

  const PlaybackControlsRow({
    super.key,
    required this.onSortSelected,
    required this.allSongs,
  });

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading:
                const Icon(Icons.access_time, color: AppColors.textPrimary),
            title: const Text('Sort by Time', style: AppTextStyles.body),
            onTap: () {
              Navigator.pop(context);
              onSortSelected("time");
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.sort_by_alpha, color: AppColors.textPrimary),
            title: const Text('Sort by Name', style: AppTextStyles.body),
            onTap: () {
              Navigator.pop(context);
              onSortSelected("name");
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: AppColors.textPrimary),
            title:
                const Text('Sort by Times Played', style: AppTextStyles.body),
            onTap: () {
              Navigator.pop(context);
              onSortSelected("timesPlayed");
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();

    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            final player = context.read<PlayerProvider>();

            // Toggle shuffle mode first
            await player.toggleShuffle();

            // If nothing is playing, start playback from a random song
            if (player.currentSong == null && allSongs.isNotEmpty) {
              final randomIndex = Random().nextInt(allSongs.length);
              await player.playFromPlaylist(allSongs, startIndex: randomIndex);
            }
          },
          child: Container(
            width: 187,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color:
                  playerProvider.isShuffling ? Colors.green : AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.shuffle, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Text(
                  'Shuffle playback',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.sort, color: AppColors.textPrimary),
          tooltip: 'Sort Songs',
          onPressed: () => _showSortOptions(context),
        ),
      ],
    );
  }
}
