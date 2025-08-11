// lib/providers/song_provider.dart

import 'package:flutter/material.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:mu_kiks/services/import.dart';

class SongProvider extends ChangeNotifier {
  List<Song> _songs = [];
  bool _isScanning = false;

  List<Song> get songs => _songs;
  bool get isScanning => _isScanning;

  /// Full scan: scans entire device for songs
  Future<void> scanSongs() async {
    await _performScan(MusicScanner.scan);
  }

  /// Quick scan: scans only a specific directory or faster path
  Future<void> quickScanSongs() async {
    await _performScan(MusicScanner.quickScan);
  }

  /// Shared scan handler for both scan types
  Future<void> _performScan(Future<List<Song>> Function() scanFunction) async {
    if (_isScanning) return; // Prevent multiple scans at the same time
    _isScanning = true;
    notifyListeners();

    try {
      final scannedSongs = await scanFunction();
      _songs = scannedSongs;
    } catch (e) {
      debugPrint('Error scanning songs: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Add a song to the list
  void addSong(Song song) {
    _songs.add(song);
    notifyListeners();
  }

  /// Remove a song from the list by id
  void removeSong(String id) {
    _songs.removeWhere((song) => song.id == id);
    notifyListeners();
  }

  /// Clear all songs
  void clearSongs() {
    _songs.clear();
    notifyListeners();
  }
}
