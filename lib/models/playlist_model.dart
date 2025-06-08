import 'package:mu_kiks/models/song_model.dart';
import 'package:uuid/uuid.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songs,
    required this.createdAt,
  });

  // ─────────────────────────────────────────────────────────────────
  // Factory to create a new playlist with auto-generated ID and timestamp
  // ─────────────────────────────────────────────────────────────────
  factory Playlist.create({required String name}) {
    return Playlist(
      id: const Uuid().v4(), // generates a unique ID
      name: name,
      songs: [],
      createdAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // JSON serialization for saving/loading
  // ─────────────────────────────────────────────────────────────────

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      songs: (json['songs'] as List<dynamic>)
          .map((item) => Song.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'songs': songs.map((song) => song.toMap()).toList(),
    };
  }

  // ─────────────────────────────────────────────────────────────────
  // Utility Methods
  // ─────────────────────────────────────────────────────────────────

  Playlist copyWith({
    String? id,
    String? name,
    List<Song>? songs,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
