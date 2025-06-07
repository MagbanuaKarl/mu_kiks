import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final String id; // Can be a UUID or path hash
  final String title;
  final String artist;
  final String album;
  final String path;
  final Duration duration;
  final String? artworkPath; // Optional local cover art

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
    this.artworkPath,
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
    };
  }

  @override
  List<Object?> get props =>
      [id, title, artist, album, path, duration, artworkPath];
}
