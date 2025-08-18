import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mu_kiks/models/import.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final _mediaItems = <MediaItem>[];

  AudioPlayer get player => _player;

  AudioPlayerHandler() {
    _forwardState();
  }

  /// Load a playlist into the queue
  Future<void> setPlaylist(List<Song> songs) async {
    _mediaItems.clear();
    _mediaItems.addAll(songs.map((s) => s.toMediaItem()).toList());

    queue.add(_mediaItems);
    await _player.setAudioSource(
      ConcatenatingAudioSource(
        children: songs.map((s) => AudioSource.uri(Uri.file(s.path))).toList(),
      ),
    );
  }

  /// Seek to a specific queue item by index
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _mediaItems.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  /// Toggle shuffle mode
  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
    final shuffleEnabled = mode == AudioServiceShuffleMode.all;
    if (_player.shuffleModeEnabled != shuffleEnabled) {
      await _player.setShuffleModeEnabled(shuffleEnabled);
    }
    playbackState.add(playbackState.value.copyWith(shuffleMode: mode));
  }

  /// Toggle repeat mode
  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    LoopMode loopMode = LoopMode.off;
    if (mode == AudioServiceRepeatMode.all) loopMode = LoopMode.all;
    if (mode == AudioServiceRepeatMode.one) loopMode = LoopMode.one;
    await _player.setLoopMode(loopMode);
    playbackState.add(playbackState.value.copyWith(repeatMode: mode));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      // wrap around to first
      await _player.seek(Duration.zero, index: 0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      // wrap around to last
      await _player.seek(Duration.zero, index: _mediaItems.length - 1);
    }
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  void _forwardState() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent(event));
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && index < _mediaItems.length) {
        mediaItem.add(_mediaItems[index]);
      }
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      playing: _player.playing,
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
      shuffleMode: _player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: {
        LoopMode.off: AudioServiceRepeatMode.none,
        LoopMode.all: AudioServiceRepeatMode.all,
        LoopMode.one: AudioServiceRepeatMode.one,
      }[_player.loopMode]!,
    );
  }
}
