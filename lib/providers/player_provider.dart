import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mu_kiks/models/import.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _playlist = [];
  int _currentIndex = 0;

  bool _isShuffling = false;
  bool _isLooping = false;
  bool _isLoopingOne = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  PlayerProvider() {
    // Listen to audio position updates
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Listen to duration updates
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    // Listen to state changes (playing, paused, completed)
    _audioPlayer.playerStateStream.listen((state) {
      final processingState = state.processingState;
      if (processingState == ProcessingState.completed) {
        if (_isLoopingOne) {
          _playCurrent();
        } else {
          next();
        }
      }
      notifyListeners();
    });
  }

  // ───────────────────────────────────────────────────────────────
  // Playback Controls
  // ───────────────────────────────────────────────────────────────

  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final song = currentSong;
    if (song != null) {
      try {
        await _audioPlayer.setFilePath(song.path);
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Error playing ${song.title}: $e');
      }
    }
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();

  void next() {
    if (_playlist.isEmpty) return;

    if (_isShuffling) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    _playCurrent();
  }

  void previous() {
    if (_currentPosition > const Duration(seconds: 3)) {
      _audioPlayer.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      _playCurrent();
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  // ───────────────────────────────────────────────────────────────
  // Shuffle & Loop Modes
  // ───────────────────────────────────────────────────────────────

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    notifyListeners();
  }

  void toggleLoopPlaylist() {
    _isLooping = !_isLooping;
    _isLoopingOne = false;
    _audioPlayer.setLoopMode(_isLooping ? LoopMode.all : LoopMode.off);
    notifyListeners();
  }

  void toggleLoopOne() {
    _isLoopingOne = !_isLoopingOne;
    _isLooping = false;
    _audioPlayer.setLoopMode(_isLoopingOne ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  int _getRandomIndex() {
    if (_playlist.length <= 1) return _currentIndex;
    int newIndex;
    do {
      newIndex = DateTime.now().millisecondsSinceEpoch % _playlist.length;
    } while (newIndex == _currentIndex);
    return newIndex;
  }

  // ───────────────────────────────────────────────────────────────
  // Getters for UI
  // ───────────────────────────────────────────────────────────────

  Song? get currentSong =>
      (_playlist.isNotEmpty && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  bool get isPlaying => _audioPlayer.playing;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isShuffling => _isShuffling;
  bool get isLooping => _isLooping;
  bool get isLoopingOne => _isLoopingOne;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  // ───────────────────────────────────────────────────────────────
  // Cleanup
  // ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
