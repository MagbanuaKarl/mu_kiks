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
      notifyListeners();
    });
  }

  // Playback controls
  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final song = currentSong;
    if (song != null) {
      await _audioPlayer.setFilePath(song.path);
      await _audioPlayer.play();
    }
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();

  void next() {
    if (_isLoopingOne) {
      _playCurrent();
      return;
    }

    _currentIndex = (_currentIndex + 1) % _playlist.length;
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

  // Getters
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
