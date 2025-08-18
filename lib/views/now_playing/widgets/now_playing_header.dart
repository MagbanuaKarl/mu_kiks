import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:mu_kiks/providers/player_provider.dart';
import 'package:mu_kiks/core/constants/styles.dart';

class NowPlayingHeader extends StatelessWidget {
  final Song song;

  const NowPlayingHeader({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Song Title
        Expanded(
          child: Text(
            song.title,
            style: AppTextStyles.headline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),

        // Favorite Icon Button
        IconButton(
          icon: Icon(
            player.isFavorite(song) ? Icons.star : Icons.star_border,
            color: Colors.amberAccent,
          ),
          onPressed: () => player.toggleFavorite(song),
        ),

        // Queue Icon Button
        IconButton(
          icon: const Icon(Icons.queue_music, color: Colors.white),
          onPressed: () {
            // TODO: Implement queue screen or modal
          },
        ),
      ],
    );
  }
}
