import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/views/import.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PlayerProvider>(
        builder: (context, player, _) {
          final song = player.currentSong;

          if (song == null) {
            return const Center(
              child: Text(
                'No song is currently playing.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 🔁 Custom App Bar
                  NowPlayingAppBar(
                    onBack: () => Navigator.pop(context),
                    onEqualizerTap: () {
                      // TODO: Implement equalizer
                    },
                  ),

                  const Spacer(),

                  // Album Art Placeholder
                  Container(
                    height: 260,
                    width: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[800],
                    ),
                    child: const Icon(Icons.music_note,
                        size: 100, color: Colors.white54),
                  ),

                  const SizedBox(height: 30),

                  // Song Title + Favorite + Queue (Refactored into a widget)
                  NowPlayingHeader(song: song),

                  const SizedBox(height: 30),

                  // Duration Slider
                  const DurationSlider(),

                  const SizedBox(height: 30),

                  // Player Controls
                  const PlayerControls(),

                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
