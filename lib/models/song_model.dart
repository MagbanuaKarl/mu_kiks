// lib/models/song_model.dart

import 'package:equatable/equatable.dart';
import 'package:audio_service/audio_service.dart';

class Song extends Equatable {
  final String id; // UUID or path hash
  final String title;
  final String artist;
  final String album;
  final String path;
  final Duration duration;
  final String? artworkPath; // Optional local cover art
  final DateTime dateAdded; // For sorting by time added
  final int playCount; // For sorting by most played

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    this.artworkPath,
    required this.dateAdded,
    this.playCount = 0,
  });

  // ---------- Persistence (Map/JSON) ----------

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: (map['title'] ?? 'Unknown Title') as String,
      artist: (map['artist'] ?? 'Unknown Artist') as String,
      album: (map['album'] ?? '') as String,
      path: map['path'] as String,
      duration: Duration(milliseconds: (map['duration'] ?? 0) as int),
      artworkPath: map['artworkPath'] as String?,
      dateAdded: map['dateAdded'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int)
          : DateTime.tryParse(map['dateAdded']?.toString() ?? '') ??
              DateTime.now(),
      playCount: (map['playCount'] is int)
          ? map['playCount'] as int
          : int.tryParse(map['playCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'path': path,
      'duration': duration.inMilliseconds,
      'artworkPath': artworkPath,
      'dateAdded': dateAdded.toIso8601String(),
      'playCount': playCount,
    };
  }

  // Aliases often used in app code
  factory Song.fromJson(Map<String, dynamic> json) => Song.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  // ---------- AudioService interop ----------

  /// Convert Song → MediaItem (used by AudioHandler queue)
  MediaItem toMediaItem() {
    return MediaItem(
      id: path, // or use `id` if you prefer UUID-based ids
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      artUri: artworkPath != null ? Uri.file(artworkPath!) : null,
      // Store all fields for round-trip safety
      extras: {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'path': path,
        'duration': duration.inMilliseconds,
        'artworkPath': artworkPath,
        'dateAdded': dateAdded.toIso8601String(),
        'playCount': playCount,
      },
    );
  }

  /// Convert MediaItem → Song (used by PlayerProvider when listening to mediaItem)
  factory Song.fromMediaItem(MediaItem item) {
    final extras = item.extras ?? const <String, dynamic>{};

    String? artworkFromExtras = extras['artworkPath'] as String?;
    String? artworkFromUri = item.artUri?.path; // file://... -> /path
    final artwork = artworkFromExtras ?? artworkFromUri;

    return Song(
      id: (extras['id'] ?? item.id).toString(),
      title: item.title,
      artist: item.artist ?? 'Unknown Artist',
      album: item.album ?? '',
      path: (extras['path'] ?? item.id).toString(),
      duration: item.duration ??
          Duration(milliseconds: (extras['duration'] ?? 0) as int),
      artworkPath: artwork,
      dateAdded: extras['dateAdded'] is int
          ? DateTime.fromMillisecondsSinceEpoch(extras['dateAdded'] as int)
          : DateTime.tryParse(extras['dateAdded']?.toString() ?? '') ??
              DateTime.now(),
      playCount: (extras['playCount'] is int)
          ? extras['playCount'] as int
          : int.tryParse(extras['playCount']?.toString() ?? '0') ?? 0,
    );
  }

  // ---------- Utilities ----------

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? path,
    Duration? duration,
    String? artworkPath,
    DateTime? dateAdded,
    int? playCount,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      artworkPath: artworkPath ?? this.artworkPath,
      dateAdded: dateAdded ?? this.dateAdded,
      playCount: playCount ?? this.playCount,
    );
  }

  bool get hasArtwork => artworkPath != null && artworkPath!.isNotEmpty;
  String get displayArtist => artist.isNotEmpty ? artist : 'Unknown Artist';

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        path,
        duration,
        artworkPath,
        dateAdded,
        playCount,
      ];
}
