import 'package:permission_handler/permission_handler.dart' as permissions;

class PermissionService {
  Future<permissions.PermissionStatus> requestCameraPermission() =>
      permissions.Permission.camera.request();

  Future<permissions.PermissionStatus> getCameraPermissionStatus() =>
      permissions.Permission.camera.status;

  Future<bool> openAppSettings() => permissions.openAppSettings();
}
