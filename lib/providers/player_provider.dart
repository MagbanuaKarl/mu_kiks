import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
// import 'package:rxdart/rxdart.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/services/audio_player_handler.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioHandler _audioHandler;
  StreamSubscription? _positionSubscription;

  PlayerProvider(this._audioHandler) {
    _init();
  }

  List<Song> _playlist = [];
  List<int> _shuffledIndices = [];
  int _currentIndex = 0;

  bool _isShuffling = false;
  bool _isLooping = false;
  bool _isLoopingOne = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final Set<String> _favoriteSongIds = {};

  void _init() {
    // Listen to playback state changes
    _audioHandler.playbackState.listen((state) {
      // In v0.18, position is not available in PlaybackState, so we'll get it directly
      notifyListeners();
    });

    // Listen to media item changes for duration updates
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        final index =
            _playlist.indexWhere((s) => s.id == mediaItem.extras?['id']);
        if (index != -1) _currentIndex = index;

        _totalDuration = mediaItem.duration ?? Duration.zero;
        notifyListeners();
      }
    });

    // Listen to queue changes
    _audioHandler.queue.listen((queue) {
      notifyListeners();
    });

    // Add position stream listener for real-time updates
    _startPositionListener();
  }

  void _startPositionListener() {
    // Cancel existing subscription if any
    _positionSubscription?.cancel();

    // Create a periodic stream to update position
    _positionSubscription =
        Stream.periodic(const Duration(milliseconds: 200)).listen((_) async {
      if (_audioHandler is AudioPlayerHandler) {
        final handler = _audioHandler;
        final position = await handler.getCurrentPosition();
        if (position != _currentPosition) {
          _currentPosition = position;
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  // ───────── Playbook Controls ─────────

  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;
    _currentIndex = startIndex;

    if (_isShuffling) _generateShuffledIndices(preserveCurrent: true);

    await (_audioHandler as AudioPlayerHandler).setPlaylist(
      _playlist,
      startIndex: _currentIndex,
    );

    // Update duration after setting playlist
    if (_playlist.isNotEmpty && startIndex < _playlist.length) {
      _totalDuration = _playlist[_currentIndex].duration;
      notifyListeners();
    }
  }

  Future<void> playFromPlaylist(List<Song> songs, Song selectedSong) async {
    final index = songs.indexWhere((s) => s.id == selectedSong.id);
    if (index == -1) return;

    await setPlaylist(songs, startIndex: index);
    await play();
  }

  Future<void> play() => _audioHandler.play();
  Future<void> pause() => _audioHandler.pause();

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  Future<void> stop() => _audioHandler.stop();

  void togglePlayPause() async {
    isPlaying ? await pause() : await play();
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

    _audioHandler.skipToQueueItem(_currentIndex);
    _updateCurrentSongInfo();
  }

  void previous() {
    if (_currentPosition > const Duration(seconds: 3)) {
      seek(Duration.zero);
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

      _audioHandler.skipToQueueItem(_currentIndex);
      _updateCurrentSongInfo();
    }
  }

  void _updateCurrentSongInfo() {
    if (_playlist.isNotEmpty && _currentIndex < _playlist.length) {
      _totalDuration = _playlist[_currentIndex].duration;
      _currentPosition = Duration.zero;
      notifyListeners();
    }
  }

  // ───────── Shuffle & Loop ─────────

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    if (_isShuffling) _generateShuffledIndices(preserveCurrent: true);
    notifyListeners();
  }

  void _generateShuffledIndices({bool preserveCurrent = false}) {
    final originalIndices = List.generate(_playlist.length, (i) => i);
    if (preserveCurrent) {
      originalIndices.remove(_currentIndex);
      originalIndices.shuffle();
      _shuffledIndices = [_currentIndex, ...originalIndices];
    } else {
      originalIndices.shuffle();
      _shuffledIndices = originalIndices;
    }
  }

  void toggleLoopPlaylist() {
    _isLooping = !_isLooping;
    _isLoopingOne = false;
    _audioHandler.setRepeatMode(
      _isLooping ? AudioServiceRepeatMode.all : AudioServiceRepeatMode.none,
    );
    notifyListeners();
  }

  void toggleLoopOne() {
    _isLoopingOne = !_isLoopingOne;
    _isLooping = false;
    _audioHandler.setRepeatMode(
      _isLoopingOne ? AudioServiceRepeatMode.one : AudioServiceRepeatMode.none,
    );
    notifyListeners();
  }

  // ───────── Favorites ─────────

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

  // ───────── UI Getters ─────────

  Song? get currentSong =>
      (_playlist.isNotEmpty && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  bool get isPlaying =>
      _audioHandler.playbackState.value.playing &&
      _audioHandler.playbackState.value.processingState !=
          AudioProcessingState.idle;

  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  bool get isShuffling => _isShuffling;
  bool get isLooping => _isLooping;
  bool get isLoopingOne => _isLoopingOne;

  List<Song> get queue => _isShuffling
      ? _shuffledIndices.map((i) => _playlist[i]).toList()
      : _playlist;

  int get currentIndex => _currentIndex;

  // ───────── Progress Stream for UI (e.g., MiniPlayer) ─────────

  Stream<double> get progressStream =>
      Stream.periodic(const Duration(milliseconds: 200)).asyncMap((_) async {
        if (_audioHandler is AudioPlayerHandler) {
          final handler = _audioHandler as AudioPlayerHandler;
          final position = await handler.getCurrentPosition();
          final duration = _totalDuration;
          if (duration.inMilliseconds == 0) return 0.0;
          return position.inMilliseconds / duration.inMilliseconds;
        }
        return 0.0;
      });
}
