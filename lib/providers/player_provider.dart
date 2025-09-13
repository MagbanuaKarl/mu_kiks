// Manages the music player itself (what’s currently playing). It’s about control (play, pause, next, seek).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mu_kiks/models/import.dart';
import 'package:mu_kiks/services/audio_player_handler.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioHandler _handler;
  final _favoriteSongIds = <String>{};

  List<Song> _playlist = [];

  StreamSubscription<PlaybackState>? _playbackSub;
  StreamSubscription<MediaItem?>? _mediaItemSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  PlayerProvider(this._handler) {
    _listenToHandler();
  }

  // --- Public getters ---
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  List<Song> get playlist => _playlist;

  bool get isShuffling =>
      _handler.playbackState.value.shuffleMode == AudioServiceShuffleMode.all;
  bool get isLoopingOne =>
      _handler.playbackState.value.repeatMode == AudioServiceRepeatMode.one;
  bool get isLooping =>
      _handler.playbackState.value.repeatMode == AudioServiceRepeatMode.all;

  Set<String> get favoriteSongIds => _favoriteSongIds;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  // --- Core playback controls ---
  Future<void> play() => _handler.play();
  Future<void> pause() => _handler.pause();

  Future<void> skipNext() async {
    if (_playlist.isEmpty) return;

    final currentIndex = _currentSong != null
        ? _playlist.indexWhere((s) => s.id == _currentSong!.id)
        : -1;
    if (currentIndex == -1) return;

    int nextIndex = (currentIndex + 1) % _playlist.length; // wrap-around

    await playFromPlaylist(_playlist, startIndex: nextIndex);
  }

  Future<void> skipPrevious() async {
    if (_playlist.isEmpty) return;

    final currentIndex = _currentSong != null
        ? _playlist.indexWhere((s) => s.id == _currentSong!.id)
        : -1;
    if (currentIndex == -1) return;

    int prevIndex = currentIndex - 1;
    if (prevIndex < 0) prevIndex = _playlist.length - 1; // wrap-around

    await playFromPlaylist(_playlist, startIndex: prevIndex);
  }

  Future<void> seek(Duration position) => _handler.seek(position);

  void togglePlayPause() {
    isPlaying ? pause() : play();
  }

  // --- Playlist management ---
  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;

    if (_handler is AudioPlayerHandler) {
      final playerHandler = _handler as AudioPlayerHandler;
      await playerHandler.setPlaylist(songs);

      if (startIndex >= 0 && startIndex < songs.length) {
        await playerHandler.skipToQueueItem(startIndex);
      }

      _positionSub?.cancel();
      _durationSub?.cancel();

      _positionSub = playerHandler.player.positionStream.listen((pos) {
        _currentPosition = pos;
        notifyListeners();
      });

      _durationSub = playerHandler.player.durationStream.listen((dur) {
        _totalDuration = dur ?? Duration.zero;
        notifyListeners();
      });
    } else {
      await _handler.customAction('setPlaylist', {
        'songs': songs.map((s) => s.toJson()).toList(),
      });
      if (startIndex >= 0 && startIndex < songs.length) {
        await _handler.skipToQueueItem(startIndex);
      }
      _totalDuration = songs[startIndex].duration;
    }

    _updateCurrentSong();
    notifyListeners();
  }

  Future<void> playFromPlaylist(
    List<Song> songs, {
    Song? startSong,
    int startIndex = 0,
  }) async {
    if (startSong != null) {
      startIndex = songs.indexWhere((s) => s.id == startSong.id);
      if (startIndex == -1) startIndex = 0;
    }

    await setPlaylist(songs, startIndex: startIndex);
    await play();
  }

  // --- Shuffle / Repeat ---
  Future<void> toggleShuffle() async {
    final state = _handler.playbackState.value;
    final newMode = state.shuffleMode == AudioServiceShuffleMode.all
        ? AudioServiceShuffleMode.none
        : AudioServiceShuffleMode.all;

    if (_handler is AudioPlayerHandler) {
      await (_handler as AudioPlayerHandler).setShuffleMode(newMode);
      notifyListeners();
    }
  }

  Future<void> toggleLoop() async {
    final current = _handler.playbackState.value.repeatMode;
    final newMode = switch (current) {
      AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
      AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
      AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
      _ => AudioServiceRepeatMode.none,
    };

    if (_handler is AudioPlayerHandler) {
      await (_handler as AudioPlayerHandler).setRepeatMode(newMode);
      notifyListeners();
    }
  }

  // --- Favorites ---
  void toggleFavorite(Song song) {
    if (_favoriteSongIds.contains(song.id)) {
      _favoriteSongIds.remove(song.id);
    } else {
      _favoriteSongIds.add(song.id);
    }
    notifyListeners();
  }

  bool isFavorite(Song song) => _favoriteSongIds.contains(song.id);

  // --- Internal listening ---
  void _listenToHandler() {
    _playbackSub = _handler.playbackState.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _mediaItemSub = _handler.mediaItem.listen((item) {
      if (item != null) {
        _currentSong = Song.fromMediaItem(item);
        _totalDuration = item.duration ?? Duration.zero;
        notifyListeners();
      }
    });
  }

  void _updateCurrentSong() {
    if (_handler is AudioPlayerHandler) {
      final idx = (_handler as AudioPlayerHandler).player.currentIndex;
      if (idx != null && idx >= 0 && idx < _playlist.length) {
        _currentSong = _playlist[idx];
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _playbackSub?.cancel();
    _mediaItemSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }
}
