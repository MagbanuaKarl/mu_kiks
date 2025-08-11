import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id; // Can be a UUID or path hash
  final String title;
  final String artist;
  final String album;
  final String path;
  final Duration duration;
  final String? artworkPath; // Optional local cover art

  // ✅ New fields
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
    this.playCount = 0, // default
  });

  // Factory to create a Song from a Map (for DB or JSON)
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      album: map['album'],
      path: map['path'],
      duration: Duration(milliseconds: map['duration']),
      artworkPath: map['artworkPath'],
      dateAdded: DateTime.tryParse(map['dateAdded'] ?? '') ?? DateTime.now(),
      playCount: map['playCount'] ?? 0,
    );
  }

  // Convert to Map (for storing in local DB)
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

  // Optional copyWith for immutability
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
