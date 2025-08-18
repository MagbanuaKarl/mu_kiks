import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:path/path.dart' as p;

/// Handles reading, writing, and deleting playlists from local storage.
class PlaylistService {
  static const _playlistFolderName = 'playlists';

  /// Returns the directory where playlists are stored.
  static Future<Directory> _getPlaylistDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final playlistDir = Directory(p.join(appDocDir.path, _playlistFolderName));
    if (!(await playlistDir.exists())) {
      await playlistDir.create(recursive: true);
    }
    return playlistDir;
  }

  /// Returns all playlists stored locally.
  static Future<List<Playlist>> loadAllPlaylists() async {
    final dir = await _getPlaylistDirectory();
    final files = dir.listSync().whereType<File>();

    List<Playlist> playlists = [];

    for (final file in files) {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        playlists.add(Playlist.fromJson(json));
      } catch (e) {
        // Skip invalid or corrupt files
        continue;
      }
    }

    return playlists;
  }

  /// Saves a playlist to a local file.
  static Future<void> savePlaylist(Playlist playlist) async {
    final dir = await _getPlaylistDirectory();
    final filePath = p.join(dir.path, '${playlist.id}.json');
    final file = File(filePath);
    final jsonString = jsonEncode(playlist.toJson());
    await file.writeAsString(jsonString);
  }

  /// Deletes a playlist by ID.
  static Future<void> deletePlaylist(String playlistId) async {
    final dir = await _getPlaylistDirectory();
    final file = File(p.join(dir.path, '$playlistId.json'));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Loads a single playlist by ID.
  static Future<Playlist?> loadPlaylistById(String playlistId) async {
    final dir = await _getPlaylistDirectory();
    final file = File(p.join(dir.path, '$playlistId.json'));
    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content);
      return Playlist.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Adds a song to a playlist and saves it.
  static Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    final updated = playlist.copyWith(
      songs: [...playlist.songs, song],
    );
    await savePlaylist(updated);
  }

  /// Removes a song from a playlist and saves it.
  static Future<void> removeSongFromPlaylist(
      Playlist playlist, Song song) async {
    final updated = playlist.copyWith(
      songs: playlist.songs.where((s) => s.id != song.id).toList(),
    );
    await savePlaylist(updated);
  }

  // Rename an exisitng playlist
  static Future<void> renamePlaylist(String playlistId, String newName) async {
    final playlist = await loadPlaylistById(playlistId);
    if (playlist != null) {
      final updated = playlist.copyWith(name: newName);
      await savePlaylist(updated);
    }
  }
}
