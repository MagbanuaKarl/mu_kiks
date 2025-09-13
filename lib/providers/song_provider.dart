// Manages your music library (the collection of available songs). It’s about data (what songs exist), not playback.

import 'package:flutter/material.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:mu_kiks/services/music_scanner.dart';

class SongProvider extends ChangeNotifier {
  List<Song> _songs = [];
  bool _isScanning = false;

  List<Song> get songs => List.unmodifiable(_songs); // expose as read-only
  bool get isScanning => _isScanning;

  /// Run a full scan (moves files + rebuilds library)
  Future<void> scanSongs() async {
    _isScanning = true;
    notifyListeners();

    try {
      _songs = await MusicScanner.scan();
      // Default sort by title (A–Z)
      _songs = MusicScanner.sortByTitle(_songs);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Quick scan (only scans MuKiks directory)
  Future<void> quickScanSongs() async {
    _isScanning = true;
    notifyListeners();

    try {
      _songs = await MusicScanner.quickScan();
      // Default sort by title
      _songs = MusicScanner.sortByTitle(_songs);
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Sorting options
  void sortByTitle({bool ascending = true}) {
    _songs = MusicScanner.sortByTitle(_songs, ascending: ascending);
    notifyListeners();
  }

  void sortByDateAdded({bool newestFirst = true}) {
    _songs = MusicScanner.sortByDateAdded(_songs, newestFirst: newestFirst);
    notifyListeners();
  }

  /// Filtering (returns a new list, does not change _songs)
  List<Song> filterSongs(String query) {
    return MusicScanner.filterSongs(_songs, query);
  }

  /// Clear library (e.g., when user logs out or resets app)
  void clearSongs() {
    _songs = [];
    notifyListeners();
  }
}
