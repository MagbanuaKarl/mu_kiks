import 'dart:io';
import 'package:mu_kiks/core/utils/permission_utils.dart';
import 'package:mu_kiks/core/utils/file_utils.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class MusicScanner {
  /// Scans device for MP3s, moves them to /Music/MuKiks, and returns list of Songs
  static Future<List<Song>> scanAndImportSongs() async {
    List<Song> songList = [];

    final hasPermission = await PermissionUtils.requestAllNeededPermissions();
    if (!hasPermission) return songList;

    // 1. Scan all .mp3 files (from whole accessible storage)
    final musicDir =
        Directory('/storage/emulated/0/Download'); // Root accessible path
    final mp3Files = await FileUtils.scanMp3Files(musicDir);

    // 2. Move to MuKiks directory
    await FileUtils.relocateMp3s(mp3Files);

    // 3. Rescan only from MuKiks folder
    final muKiksDir = await FileUtils.getMuKiksMusicDirectory();
    final muKiksMp3s = await FileUtils.scanMp3Files(muKiksDir);

    // 4. Convert files to Song objects
    for (var file in muKiksMp3s) {
      final duration = await _getDurationPlaceholder(file);
      final name = p.basenameWithoutExtension(file.path);

      final song = Song(
        id: const Uuid().v4(),
        title: name,
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        path: file.path,
        duration: duration,
      );

      songList.add(song);
    }

    return songList;
  }

  /// Placeholder: Just returns a dummy duration
  static Future<Duration> _getDurationPlaceholder(File file) async {
    // Use actual duration parser later with `just_audio` or `flutter_media_metadata`
    return const Duration(minutes: 3); // Temporary fixed value
  }
}
