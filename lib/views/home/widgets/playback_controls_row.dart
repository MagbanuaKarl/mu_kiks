import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

class PlaybackControlsRow extends StatelessWidget {
  const PlaybackControlsRow({super.key});

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
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading:
                const Icon(Icons.sort_by_alpha, color: AppColors.textPrimary),
            title: const Text('Sort by Name', style: AppTextStyles.body),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: AppColors.textPrimary),
            title:
                const Text('Sort by Times Played', style: AppTextStyles.body),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            debugPrint('Shuffle playback tapped');
          },
          child: Container(
            width: 187, // Optional: Set a fixed width or use constraints
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
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
