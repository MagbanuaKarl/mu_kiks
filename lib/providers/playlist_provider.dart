import 'package:flutter/material.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/services/import.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];

  List<Playlist> get playlists => _playlists;

  /// Load all playlists from local storage
  Future<void> loadPlaylists() async {
    _playlists = await PlaylistService.loadAllPlaylists();
    notifyListeners();
  }

  /// Create and save a new playlist
  Future<void> createPlaylist(String name) async {
    final newPlaylist = Playlist.create(name: name);
    _playlists.add(newPlaylist);
    await PlaylistService.savePlaylist(newPlaylist);
    notifyListeners();
  }

  /// Delete an existing playlist
  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await PlaylistService.deletePlaylist(playlistId);
    notifyListeners();
  }

  /// Add a song to a specific playlist
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    if (!playlist.songs.any((s) => s.id == song.id)) {
      final updated = playlist.copyWith(
        songs: [...playlist.songs, song],
      );
      _playlists[index] = updated;
      await PlaylistService.savePlaylist(updated);
      notifyListeners();
    }
  }

  /// Remove a song from a specific playlist
  Future<void> removeSongFromPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    final updated = playlist.copyWith(
      songs: playlist.songs.where((s) => s.id != song.id).toList(),
    );
    _playlists[index] = updated;
    await PlaylistService.savePlaylist(updated);
    notifyListeners();
  }

  Playlist? getPlaylistById(String playlistId) {
    return _playlists.where((p) => p.id == playlistId).firstOrNull;
  }
}
