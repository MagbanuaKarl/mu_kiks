import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:mu_kiks/providers/import.dart';
import 'package:mu_kiks/views/import.dart';
import 'package:mu_kiks/widgets/import.dart';
import 'package:mu_kiks/core/import.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final Song? currentSong = player.currentSong;

    if (currentSong == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            const RotatingDisc(),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 18,
                child: MarqueeText(
                  text: currentSong.title,
                  style: AppTextStyles.subhead.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            StreamBuilder<double>(
              stream: player.progressStream,
              initialData: 0.0,
              builder: (context, snapshot) {
                final progress = snapshot.data ?? 0.0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 2.5,
                        backgroundColor:
                            AppColors.textSecondary.withOpacity(0.2),
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        player.isPlaying ? player.pause() : player.play();
                      },
                    ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_next,
                color: AppColors.textPrimary,
              ),
              onPressed: player.next,
            ),
          ],
        ),
      ),
    );
  }
}
