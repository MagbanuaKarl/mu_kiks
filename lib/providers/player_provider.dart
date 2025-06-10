import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mu_kiks/models/import.dart';
import 'dart:math';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _playlist = []; // Original ordered playlist
  List<int> _shuffledIndices = []; // Index order for shuffle
  int _currentIndex = 0;

  bool _isShuffling = false;
  bool _isLooping = false;
  bool _isLoopingOne = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  PlayerProvider() {
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_isLoopingOne) {
          _playCurrent();
        } else {
          next();
        }
      }
      notifyListeners();
    });
  }

  // ───────────────────────────────────────────────
  // Playback Controls
  // ───────────────────────────────────────────────

  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;
    _currentIndex = startIndex;

    if (_isShuffling) {
      _generateShuffledIndices(preserveCurrent: true);
    }

    await _playCurrent();
    notifyListeners();
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

    if (_isShuffling && _shuffledIndices.isNotEmpty) {
      int currentShufflePos = _shuffledIndices.indexOf(_currentIndex);
      int nextShufflePos = (currentShufflePos + 1) % _shuffledIndices.length;
      _currentIndex = _shuffledIndices[nextShufflePos];
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }

    _playCurrent();
    notifyListeners();
  }

  void previous() {
    if (_currentPosition > const Duration(seconds: 3)) {
      _audioPlayer.seek(Duration.zero);
    } else {
      if (_isShuffling && _shuffledIndices.isNotEmpty) {
        int currentShufflePos = _shuffledIndices.indexOf(_currentIndex);
        int prevShufflePos = (currentShufflePos - 1 + _shuffledIndices.length) %
            _shuffledIndices.length;
        _currentIndex = _shuffledIndices[prevShufflePos];
      } else {
        _currentIndex =
            (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }

      _playCurrent();
    }

    notifyListeners();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  // ───────────────────────────────────────────────
  // Shuffle & Loop Modes
  // ───────────────────────────────────────────────

  void toggleShuffle() {
    _isShuffling = !_isShuffling;

    if (_isShuffling) {
      _generateShuffledIndices(preserveCurrent: true);
    }

    notifyListeners();
  }

  void _generateShuffledIndices({bool preserveCurrent = false}) {
    final originalIndices = List.generate(_playlist.length, (i) => i);

    if (preserveCurrent) {
      originalIndices.remove(_currentIndex);
      originalIndices.shuffle(Random());
      _shuffledIndices = [_currentIndex, ...originalIndices];
    } else {
      originalIndices.shuffle(Random());
      _shuffledIndices = originalIndices;
    }
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

  // ───────────────────────────────────────────────
  // Getters for UI
  // ───────────────────────────────────────────────

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
  List<Song> get queue => _isShuffling
      ? _shuffledIndices.map((i) => _playlist[i]).toList()
      : _playlist;
  int get currentIndex => _currentIndex;

  // ───────────────────────────────────────────────
  // Cleanup
  // ───────────────────────────────────────────────

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
