import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileUtils {
  /// Get the MuKiks music folder inside user's Music directory
  static Future<Directory> getMuKiksMusicDirectory() async {
    final musicDir =
        await getExternalStorageDirectory(); // Typically Android/data/...
    final muKiksDir = Directory(
        p.join(musicDir!.parent.parent.parent.parent.path, 'Music', 'MuKiks'));

    if (!await muKiksDir.exists()) {
      await muKiksDir.create(recursive: true);
    }

    return muKiksDir;
  }

  /// Scan a given folder for .mp3 files (recursively)
  static Future<List<File>> scanMp3Files(Directory root) async {
    List<File> mp3Files = [];

    await for (var entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
        mp3Files.add(entity);
      }
    }

    return mp3Files;
  }

  /// Move .mp3 file to MuKiks music directory (preserve file name)

  // For testing
  // static Future<File> moveFileToMuKiks(File file) async {
  //   final muKiksDir = await getMuKiksMusicDirectory();
  //   final newPath = p.join(muKiksDir.path, p.basename(file.path));
  //   final newFile =
  //       await file.copy(newPath); // Can also use .rename() but copy is safer
  //   return newFile;
  // }

  // For Release
  static Future<File> moveFileToMuKiks(File file) async {
    final muKiksDir = await getMuKiksMusicDirectory();
    final newPath = p.join(muKiksDir.path, p.basename(file.path));
    final newFile = await file.rename(newPath); // Actually moves the file
    return newFile;
  }

  /// Ensure .mp3 files are all inside MuKiks directory
  static Future<void> relocateMp3s(List<File> files) async {
    final muKiksDir = await getMuKiksMusicDirectory();
    for (var file in files) {
      if (!file.path.startsWith(muKiksDir.path)) {
        await moveFileToMuKiks(file);
      }
    }
  }
}
