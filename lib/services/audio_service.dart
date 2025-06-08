import 'dart:math';
import 'package:mu_kiks/models/song_model.dart';

class AudioService {
  final List<Song> _originalQueue = [];
  final List<int> _shuffleOrder = [];

  int _currentIndex = 0;
  bool _isShuffling = false;

  /// Load a new playlist and reset state
  void setQueue(List<Song> songs, {int startIndex = 0}) {
    _originalQueue
      ..clear()
      ..addAll(songs);

    _currentIndex = startIndex.clamp(0, _originalQueue.length - 1);
    _shuffleOrder.clear();
    _generateShuffleOrder();
  }

  void _generateShuffleOrder() {
    final indices = List<int>.generate(_originalQueue.length, (i) => i);
    indices.shuffle(Random());
    _shuffleOrder
      ..clear()
      ..addAll(indices);

    // Ensure current index is first in shuffle order
    if (_shuffleOrder.contains(_currentIndex)) {
      _shuffleOrder.remove(_currentIndex);
    }
    _shuffleOrder.insert(0, _currentIndex);
  }

  /// Returns the current song based on state
  Song? get currentSong {
    if (_originalQueue.isEmpty) return null;
    return _originalQueue[_currentIndex];
  }

  /// Go to the next song in queue or shuffle order
  void next() {
    if (_originalQueue.isEmpty) return;

    if (_isShuffling) {
      final currentShuffleIndex = _shuffleOrder.indexOf(_currentIndex);
      final nextShuffleIndex = (currentShuffleIndex + 1) % _shuffleOrder.length;
      _currentIndex = _shuffleOrder[nextShuffleIndex];
    } else {
      _currentIndex = (_currentIndex + 1) % _originalQueue.length;
    }
  }

  /// Go to the previous song in queue or shuffle order
  void previous() {
    if (_originalQueue.isEmpty) return;

    if (_isShuffling) {
      final currentShuffleIndex = _shuffleOrder.indexOf(_currentIndex);
      final prevShuffleIndex =
          (currentShuffleIndex - 1 + _shuffleOrder.length) %
              _shuffleOrder.length;
      _currentIndex = _shuffleOrder[prevShuffleIndex];
    } else {
      _currentIndex =
          (_currentIndex - 1 + _originalQueue.length) % _originalQueue.length;
    }
  }

  /// Directly jump to a song by index
  void jumpTo(int index) {
    if (index >= 0 && index < _originalQueue.length) {
      _currentIndex = index;
    }
  }

  /// Shuffle toggle
  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    if (_isShuffling) _generateShuffleOrder();
  }

  bool get isShuffling => _isShuffling;
  int get currentIndex => _currentIndex;
  List<Song> get currentQueue => List.unmodifiable(_originalQueue);
}
