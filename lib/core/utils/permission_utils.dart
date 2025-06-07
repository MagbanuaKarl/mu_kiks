import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    final result = await Permission.storage.request();
    return result.isGranted;
  }

  static Future<bool> requestManageExternalStorage() async {
    // For Android 11+
    final status = await Permission.manageExternalStorage.status;
    if (status.isGranted) return true;

    final result = await Permission.manageExternalStorage.request();
    return result.isGranted;
  }

  static Future<bool> requestAllNeededPermissions() async {
    bool storageGranted = await requestStoragePermission();
    bool manageStorageGranted = await requestManageExternalStorage();

    return storageGranted && manageStorageGranted;
  }
}
