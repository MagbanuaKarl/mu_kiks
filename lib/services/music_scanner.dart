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

    // 1. Scan all .mp3 files from entire external storage (with error handling)
    final rootDir =
        Directory('/storage/emulated/0'); // Root of external storage
    final mp3Files = await _scanMp3FilesWithErrorHandling(rootDir);

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

  /// Scans for MP3 files with error handling for restricted directories
  static Future<List<File>> _scanMp3FilesWithErrorHandling(
      Directory directory) async {
    List<File> mp3Files = [];

    // Directories to skip (restricted or irrelevant)
    final skipDirectoryNames = {
      'Android',
      '.thumbnails',
      '.trash',
      'lost+found',
    };

    await _scanDirectoryRecursively(directory, mp3Files, skipDirectoryNames);
    return mp3Files;
  }

  /// Recursively scans directories while avoiding restricted ones
  static Future<void> _scanDirectoryRecursively(Directory directory,
      List<File> mp3Files, Set<String> skipDirectoryNames) async {
    try {
      await for (var entity in directory.list(followLinks: false)) {
        try {
          if (entity is File) {
            // Check if it's an MP3 file
            if (entity.path.toLowerCase().endsWith('.mp3')) {
              mp3Files.add(entity);
            }
          } else if (entity is Directory) {
            // Check if we should skip this directory
            final dirName = p.basename(entity.path);
            if (skipDirectoryNames.contains(dirName)) {
              continue; // Skip this directory entirely
            }

            // Recursively scan the subdirectory
            await _scanDirectoryRecursively(
                entity, mp3Files, skipDirectoryNames);
          }
        } catch (e) {
          // Skip individual files/directories that can't be accessed
          continue;
        }
      }
    } catch (e) {
      // Skip directories that can't be accessed
      // print('Skipping directory ${directory.path}: Access denied');
    }
  }

  /// Placeholder: Just returns a dummy duration
  static Future<Duration> _getDurationPlaceholder(File file) async {
    // Use actual duration parser later with `just_audio` or `flutter_media_metadata`
    return const Duration(minutes: 3); // Temporary fixed value
  }
}
