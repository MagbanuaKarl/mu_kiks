import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/providers/import.dart';

class DurationSlider extends StatelessWidget {
  const DurationSlider({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final position = player.currentPosition;
        final total = player.totalDuration;

        final isValid = total > Duration.zero;

        return Column(
          children: [
            Slider(
              value: isValid
                  ? position.inMilliseconds
                      .clamp(0, total.inMilliseconds)
                      .toDouble()
                  : 0.0,
              max: isValid ? total.inMilliseconds.toDouble() : 1.0,
              onChanged: isValid
                  ? (value) {
                      player.seek(Duration(milliseconds: value.round()));
                    }
                  : null,
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.grey.shade400,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70)),
                  Text(_formatDuration(total),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
