import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';

Future<void> showConfirmDeleteDialog({
  required BuildContext context,
  required String playlistName,
  required VoidCallback onConfirm,
}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.background,
      title: Text('Delete Playlist', style: AppTextStyles.headline),
      content: Text(
        'Are you sure you want to delete "$playlistName"? This action cannot be undone.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          child: Text('Cancel',
              style: AppTextStyles.button
                  .copyWith(color: AppColors.textSecondary)),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Delete',
              style: AppTextStyles.button.copyWith(color: Colors.redAccent)),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    ),
  );
}
