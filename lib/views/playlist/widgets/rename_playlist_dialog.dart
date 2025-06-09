// lib/views/playlist/widgets/rename_playlist_dialog.dart

import 'package:flutter/material.dart';
import 'package:mu_kiks/core/import.dart';
import 'package:mu_kiks/models/import.dart';

Future<void> showRenamePlaylistDialog({
  required BuildContext context,
  required Playlist playlist,
  required Function(String newName) onRename,
}) async {
  final controller = TextEditingController(text: playlist.name);
  String? errorText;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.background,
          title: Text('Rename Playlist', style: AppTextStyles.headline),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'New name',
              hintStyle: AppTextStyles.body,
              errorText: errorText,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textSecondary),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.textSecondary)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Rename', style: AppTextStyles.button),
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  setState(() => errorText = 'Name cannot be empty');
                  return;
                }
                Navigator.pop(context);
                onRename(newName);
              },
            ),
          ],
        ),
      );
    },
  );
}
