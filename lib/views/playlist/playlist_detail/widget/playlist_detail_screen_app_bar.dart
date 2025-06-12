import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

class PlaylistDetailScreenAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const PlaylistDetailScreenAppBar({
    super.key,
    required this.onBack,
    required this.onRename,
    required this.onDelete,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename Playlist', style: AppTextStyles.body),
              onTap: () {
                Navigator.pop(context);
                onRename();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete,
                color: AppColors.error,
              ),
              title: const Text('Delete Playlist', style: AppTextStyles.body),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: onBack,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () => _showOptions(context),
        ),
      ],
    );
  }
}
