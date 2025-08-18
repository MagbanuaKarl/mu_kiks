// lib/services/music_scanner.dart

import 'dart:io';
import 'package:mu_kiks/core/utils/permission_utils.dart';
import 'package:mu_kiks/core/utils/file_utils.dart';
import 'package:mu_kiks/models/song_model.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class MusicScanner {
  /// Full scan: finds MP3s, moves them to /Music/MuKiks, then returns as Song objects.
  static Future<List<Song>> scan() async {
    List<Song> songList = [];

    final hasPermission = await PermissionUtils.requestAllNeededPermissions();
    if (!hasPermission) {
      return songList;
    }

    // 1. Find all MP3s from external storage
    final rootDir = Directory('/storage/emulated/0');
    final mp3Files = await _scanMp3FilesWithErrorHandling(rootDir);

    // 2. Move them to MuKiks music folder
    await FileUtils.relocateMp3s(mp3Files);

    // 3. Rescan only in MuKiks directory
    final muKiksDir = await FileUtils.getMuKiksMusicDirectory();
    final muKiksMp3s = await FileUtils.scanMp3Files(muKiksDir);

    // 4. Convert to Song objects
    for (var file in muKiksMp3s) {
      final duration = await _getDurationPlaceholder(file);
      final name = p.basenameWithoutExtension(file.path);
      final fileStat = await file.stat();

      songList.add(Song(
        id: const Uuid().v4(),
        title: name,
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        path: file.path,
        duration: duration,
        dateAdded: fileStat.changed,
      ));
    }

    return songList;
  }

  /// Quick scan of MuKiks folder (no moving files)
  static Future<List<Song>> quickScan() async {
    List<Song> songList = [];

    final muKiksDir = await FileUtils.getMuKiksMusicDirectory();
    final muKiksMp3s = await FileUtils.scanMp3Files(muKiksDir);

    for (var file in muKiksMp3s) {
      final duration = await _getDurationPlaceholder(file);
      final name = p.basenameWithoutExtension(file.path);
      final fileStat = await file.stat();

      songList.add(Song(
        id: const Uuid().v4(),
        title: name,
        artist: 'Unknown Artist',
        album: 'Unknown Album',
        path: file.path,
        duration: duration,
        dateAdded: fileStat.changed,
      ));
    }

    return songList;
  }

  /// Private helpers
  static Future<List<File>> _scanMp3FilesWithErrorHandling(
      Directory directory) async {
    List<File> mp3Files = [];
    final skipDirectoryNames = {
      'Android',
      '.thumbnails',
      '.trash',
      'lost+found',
    };

    await _scanDirectoryRecursively(directory, mp3Files, skipDirectoryNames);
    return mp3Files;
  }

  static Future<void> _scanDirectoryRecursively(Directory directory,
      List<File> mp3Files, Set<String> skipDirectoryNames) async {
    try {
      await for (var entity in directory.list(followLinks: false)) {
        try {
          if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
            mp3Files.add(entity);
          } else if (entity is Directory) {
            final dirName = p.basename(entity.path);
            if (!skipDirectoryNames.contains(dirName)) {
              await _scanDirectoryRecursively(
                  entity, mp3Files, skipDirectoryNames);
            }
          }
        } catch (_) {
          continue;
        }
      }
    } catch (_) {
      print('Skipping directory ${directory.path}: Access denied');
    }
  }

  static Future<Duration> _getDurationPlaceholder(File file) async {
    // TODO: Replace with real duration extraction
    return const Duration(minutes: 3);
  }
}
