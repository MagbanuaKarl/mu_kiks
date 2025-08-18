import 'package:mu_kiks/models/song_model.dart';

class SongQueue {
  final List<Song> songs;
  final int currentIndex;

  const SongQueue({
    required this.songs,
    required this.currentIndex,
  });

  // ──────────────────────────────────────────────────────
  // JSON Serialization (for persistence, optional)
  // ──────────────────────────────────────────────────────

  factory SongQueue.fromJson(Map<String, dynamic> json) {
    return SongQueue(
      songs: (json['songs'] as List<dynamic>)
          .map((item) => Song.fromMap(item))
          .toList(),
      currentIndex: json['currentIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'songs': songs.map((s) => s.toMap()).toList(),
      'currentIndex': currentIndex,
    };
  }

  // ──────────────────────────────────────────────────────
  // Utilities
  // ──────────────────────────────────────────────────────

  SongQueue copyWith({
    List<Song>? songs,
    int? currentIndex,
  }) {
    return SongQueue(
      songs: songs ?? this.songs,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  Song? get currentSong =>
      (songs.isNotEmpty && currentIndex >= 0 && currentIndex < songs.length)
          ? songs[currentIndex]
          : null;

  bool get hasNext => currentIndex < songs.length - 1;
  bool get hasPrevious => currentIndex > 0;

  int get length => songs.length;
}
