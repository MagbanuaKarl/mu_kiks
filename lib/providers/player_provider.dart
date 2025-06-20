import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mu_kiks/models/import.dart';
import 'dart:math';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final Stream<double> progressStream;

  List<Song> _playlist = [];
  List<int> _shuffledIndices = [];
  int _currentIndex = 0;

  bool _isShuffling = false;
  bool _isLooping = false;
  bool _isLoopingOne = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final Set<String> _favoriteSongIds = {}; // ⭐ Favorites storage

  PlayerProvider() {
    // Stream for circular progress
    progressStream = _audioPlayer.positionStream.map((position) {
      final duration = _audioPlayer.duration ?? Duration.zero;
      if (duration.inMilliseconds == 0) return 0.0;
      return position.inMilliseconds / duration.inMilliseconds;
    }).asBroadcastStream();

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

    _audioPlayer.playingStream.listen((_) {
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

    await _prepareCurrent();
    notifyListeners();
  }

  Future<void> playFromPlaylist(List<Song> songs, Song selectedSong) async {
    final index = songs.indexWhere((s) => s.id == selectedSong.id);
    if (index == -1) return;

    await setPlaylist(songs, startIndex: index);
    await _playCurrent(); // Ensures audio is prepared before playing
  }

  Future<void> _prepareCurrent() async {
    final song = currentSong;
    if (song != null) {
      try {
        await _audioPlayer.setFilePath(song.path);
      } catch (e) {
        debugPrint('Error preparing ${song.title}: $e');
      }
    }
  }

  Future<void> _playCurrent() async {
    await _prepareCurrent();
    await _audioPlayer.play();
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();

  void togglePlayPause() {
    isPlaying ? pause() : play();
    notifyListeners();
  }

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
  // Favorites Management
  // ───────────────────────────────────────────────

  void toggleFavorite(Song song) {
    if (_favoriteSongIds.contains(song.id)) {
      _favoriteSongIds.remove(song.id);
    } else {
      _favoriteSongIds.add(song.id);
    }
    notifyListeners();
  }

  bool isFavorite(Song song) => _favoriteSongIds.contains(song.id);

  Set<String> get favoriteSongIds => _favoriteSongIds;

  // ───────────────────────────────────────────────
  // Getters for UI
  // ───────────────────────────────────────────────

  Song? get currentSong =>
      (_playlist.isNotEmpty && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  bool get isPlaying => _audioPlayer.playing;
  bool get hasActiveSong => currentSong != null;

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
