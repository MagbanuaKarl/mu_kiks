import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionUtils {
  static Future<bool> requestAllNeededPermissions() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    print('Android SDK Version: $sdkInt');

    if (sdkInt >= 33) {
      // Android 13+ (Tiramisu+): Use audio permission
      final audioStatus = await Permission.audio.request();
      return audioStatus.isGranted;
    } else if (sdkInt >= 30) {
      // Android 11–12: MANAGE_EXTERNAL_STORAGE
      final manageStatus = await Permission.manageExternalStorage.request();

      if (!manageStatus.isGranted) {
        await openAppSettings(); // Optional: guide user to manually allow
      }

      return manageStatus.isGranted;
    } else {
      // Android 10 and below: legacy storage
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
  }
}
