import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/providers/import.dart';
import 'package:mu_kiks/core/import.dart';

class AddToPlaylistDialog extends StatefulWidget {
  final Song? song;
  final bool isCreatingNew;

  const AddToPlaylistDialog({
    super.key,
    this.song,
    this.isCreatingNew = false,
  });

  @override
  State<AddToPlaylistDialog> createState() => _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends State<AddToPlaylistDialog> {
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);

    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        widget.isCreatingNew ? 'Create New Playlist' : 'Add to Playlist',
        style: AppTextStyles.headline,
      ),
      content: widget.isCreatingNew
          ? TextField(
              controller: _controller,
              autofocus: true,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: AppTextStyles.body,
                errorText: errorText,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            )
          : SizedBox(
              width: double.maxFinite,
              height: 200,
              child: playlistProvider.playlists.isEmpty
                  ? const Center(
                      child: Text(
                        'No playlists found.',
                        style: AppTextStyles.body,
                      ),
                    )
                  : ListView.builder(
                      itemCount: playlistProvider.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlistProvider.playlists[index];
                        return ListTile(
                          title: Text(
                            playlist.name,
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textPrimary),
                          ),
                          onTap: () {
                            if (widget.song != null) {
                              playlistProvider.addSongToPlaylist(
                                  playlist.id, widget.song!);
                              context.showSuccessSnackBar(
                                  'Added to "${playlist.name}"');
                            }
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
      actions: [
        TextButton(
          child: Text('Cancel',
              style: AppTextStyles.button
                  .copyWith(color: AppColors.textSecondary)),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
        ),
        if (widget.isCreatingNew)
          TextButton(
            child: Text('Create', style: AppTextStyles.button),
            onPressed: () {
              final name = _controller.text.trim();
              if (name.isEmpty) {
                setState(() {
                  errorText = 'Name can\'t be empty';
                });
                return;
              }
              if (playlistProvider.playlists.any((p) => p.name == name)) {
                setState(() {
                  errorText = 'Playlist already exists';
                });
                return;
              }

              playlistProvider.createPlaylist(name);
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}
