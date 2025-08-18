import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:mu_kiks/models/song_model.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  final List<Song> _originalQueue = [];
  final List<int> _shuffleOrder = [];

  int _currentIndex = 0;
  bool _isShuffling = false;
  bool _isLooping = false;
  bool _isLoopingOne = false;

  /// Load a new playlist and optionally start at a specific index
  Future<void> setQueue(List<Song> songs, {int startIndex = 0}) async {
    _originalQueue
      ..clear()
      ..addAll(songs);

    _currentIndex = startIndex.clamp(0, _originalQueue.length - 1);
    _shuffleOrder.clear();

    if (_isShuffling) _generateShuffleOrder();

    await _playCurrent();
  }

  void _generateShuffleOrder() {
    final indices = List<int>.generate(_originalQueue.length, (i) => i);
    indices.shuffle(Random());
    _shuffleOrder
      ..clear()
      ..addAll(indices);

    // Ensure current index is first
    _shuffleOrder.remove(_currentIndex);
    _shuffleOrder.insert(0, _currentIndex);
  }

  Future<void> _playCurrent() async {
    final song = currentSong;
    if (song != null) {
      try {
        await _player.setFilePath(song.path);
        await _player.play();
      } catch (e) {
        print('Error playing ${song.title}: $e');
      }
    }
  }

  /// Playback controls
  void play() => _player.play();
  void pause() => _player.pause();
  void seek(Duration position) => _player.seek(position);

  Future<void> next() async {
    if (_originalQueue.isEmpty) return;

    if (_isShuffling && _shuffleOrder.isNotEmpty) {
      final currentShuffleIndex = _shuffleOrder.indexOf(_currentIndex);
      final nextIndex = (currentShuffleIndex + 1) % _shuffleOrder.length;
      _currentIndex = _shuffleOrder[nextIndex];
    } else {
      _currentIndex = (_currentIndex + 1) % _originalQueue.length;
    }

    await _playCurrent();
  }

  Future<void> previous() async {
    if (_originalQueue.isEmpty) return;

    if (_player.position > const Duration(seconds: 3)) {
      _player.seek(Duration.zero);
    } else {
      if (_isShuffling && _shuffleOrder.isNotEmpty) {
        final currentShuffleIndex = _shuffleOrder.indexOf(_currentIndex);
        final prevIndex = (currentShuffleIndex - 1 + _shuffleOrder.length) %
            _shuffleOrder.length;
        _currentIndex = _shuffleOrder[prevIndex];
      } else {
        _currentIndex =
            (_currentIndex - 1 + _originalQueue.length) % _originalQueue.length;
      }

      await _playCurrent();
    }
  }

  Future<void> jumpTo(int index) async {
    if (index >= 0 && index < _originalQueue.length) {
      _currentIndex = index;
      await _playCurrent();
    }
  }

  /// Shuffle toggle
  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    if (_isShuffling) _generateShuffleOrder();
  }

  /// Loop toggle
  void toggleLoopPlaylist() {
    _isLooping = !_isLooping;
    _isLoopingOne = false;
    _player.setLoopMode(_isLooping ? LoopMode.all : LoopMode.off);
  }

  void toggleLoopOne() {
    _isLoopingOne = !_isLoopingOne;
    _isLooping = false;
    _player.setLoopMode(_isLoopingOne ? LoopMode.one : LoopMode.off);
  }

  /// Accessors
  Song? get currentSong =>
      (_originalQueue.isNotEmpty && _currentIndex < _originalQueue.length)
          ? _originalQueue[_currentIndex]
          : null;

  bool get isShuffling => _isShuffling;
  bool get isLooping => _isLooping;
  bool get isLoopingOne => _isLoopingOne;
  int get currentIndex => _currentIndex;
  List<Song> get currentQueue => List.unmodifiable(_originalQueue);

  Duration get currentPosition => _player.position;
  Duration get totalDuration => _player.duration ?? Duration.zero;
  bool get isPlaying => _player.playing;

  AudioPlayer get rawPlayer => _player;

  void dispose() {
    _player.dispose();
  }
}
