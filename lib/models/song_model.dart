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
  final int fileSizeBytes; // New field: file size in bytes

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
    required this.fileSizeBytes, // new field
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
      fileSizeBytes: (map['fileSizeBytes'] is int)
          ? map['fileSizeBytes'] as int
          : int.tryParse(map['fileSizeBytes']?.toString() ?? '0') ?? 0,
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
      'fileSizeBytes': fileSizeBytes,
    };
  }

  // Aliases often used in app code
  factory Song.fromJson(Map<String, dynamic> json) => Song.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  // ---------- AudioService interop ----------
  MediaItem toMediaItem() {
    return MediaItem(
      id: path,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      artUri: artworkPath != null ? Uri.file(artworkPath!) : null,
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
        'fileSizeBytes': fileSizeBytes,
      },
    );
  }

  factory Song.fromMediaItem(MediaItem item) {
    final extras = item.extras ?? const <String, dynamic>{};
    String? artworkFromExtras = extras['artworkPath'] as String?;
    String? artworkFromUri = item.artUri?.path;
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
      fileSizeBytes: (extras['fileSizeBytes'] is int)
          ? extras['fileSizeBytes'] as int
          : int.tryParse(extras['fileSizeBytes']?.toString() ?? '0') ?? 0,
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
    int? fileSizeBytes,
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
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
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
        fileSizeBytes,
      ];
}
