import 'package:flutter/material.dart';
import 'package:mu_kiks/core/constants/colors.dart';

class NowPlayingAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEqualizerTap;

  const NowPlayingAppBar({
    super.key,
    required this.onBack,
    required this.onEqualizerTap,
  });

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.white),
              title: const Text('Sleep Timer',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Sleep Timer
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.white),
              title: const Text('Ringtone Editor',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Ringtone Editor
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit Song Info',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Edit Song Info
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.remove_circle_outline, color: Colors.white),
              title: const Text('Remove from queue',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement Remove from Queue
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),

        // Right-side Buttons
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.settings_input_component,
                  color: Colors.white),
              onPressed: onEqualizerTap,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () => _showOptionsSheet(context),
            ),
          ],
        ),
      ],
    );
  }
}
