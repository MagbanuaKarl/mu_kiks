import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mu_kiks/models/import.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  List<MediaItem> _mediaItems = [];

  AudioPlayerHandler() {
    _forwardPlaybackState();
    _listenToCurrentIndex();
    _listenToDuration();
  }

  void _forwardPlaybackState() {
    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processingState = _transformProcessingState(state.processingState);

      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: playing,
        bufferedPosition: _player.bufferedPosition,
        updateTime: DateTime.now(),
        speed: _player.speed,
      ));
    });
  }

  void _listenToCurrentIndex() {
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _mediaItems.length) {
        mediaItem.add(_mediaItems[index]);
      }
    });
  }

  void _listenToDuration() {
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      if (duration != null && index != null && index < _mediaItems.length) {
        final old = _mediaItems[index];
        final updated = old.copyWith(duration: duration);
        _mediaItems[index] = updated;
        mediaItem.add(updated);
      }
    });
  }

  // Method to get current position (used by PlayerProvider)
  Future<Duration> getCurrentPosition() async {
    return _player.position;
  }

  // Method to get current duration
  Duration? getCurrentDuration() {
    return _player.duration;
  }

  // ─────────────── Queue Setup ───────────────

  Future<void> setPlaylist(List<Song> songs, {int startIndex = 0}) async {
    _mediaItems = songs.map(_songToMediaItem).toList();
    queue.add(_mediaItems);

    try {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children:
              songs.map((s) => AudioSource.uri(Uri.file(s.path))).toList(),
        ),
        initialIndex: startIndex,
      );

      if (startIndex < _mediaItems.length) {
        mediaItem.add(_mediaItems[startIndex]);
      }
    } catch (e) {
      print('Error setting playlist: $e');
    }
  }

  MediaItem _songToMediaItem(Song song) {
    return MediaItem(
      id: song.path,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      artUri: song.artworkPath != null ? Uri.file(song.artworkPath!) : null,
      extras: {'id': song.id}, // Store the song ID for identification
    );
  }

  // ─────────────── Playback Controls ───────────────

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      print('Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      await _player.seekToNext();
    } catch (e) {
      print('Error skipping to next: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      await _player.seekToPrevious();
    } catch (e) {
      print('Error skipping to previous: $e');
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _mediaItems.length) {
      try {
        await _player.seek(Duration.zero, index: index);
        mediaItem.add(_mediaItems[index]);
      } catch (e) {
        print('Error skipping to queue item: $e');
      }
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    try {
      switch (repeatMode) {
        case AudioServiceRepeatMode.none:
          await _player.setLoopMode(LoopMode.off);
          break;
        case AudioServiceRepeatMode.one:
          await _player.setLoopMode(LoopMode.one);
          break;
        case AudioServiceRepeatMode.all:
          await _player.setLoopMode(LoopMode.all);
          break;
        default:
          break;
      }
    } catch (e) {
      print('Error setting repeat mode: $e');
    }
  }

  // ─────────────── Utility ───────────────

  AudioProcessingState _transformProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  Future<void> close() async {
    await _player.dispose();
  }
}
