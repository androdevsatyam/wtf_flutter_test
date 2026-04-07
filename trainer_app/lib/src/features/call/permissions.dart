import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class CallPermissions {
  static Future<void> ensure() async {
    if (Platform.isIOS) {
      await Permission.camera.request();
      await Permission.microphone.request();
      return;
    }

    await _requestUntilGranted(Permission.camera);
    await _requestUntilGranted(Permission.microphone);
    await Permission.bluetoothConnect.request();
  }

  static Future<void> _requestUntilGranted(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted) return;

    status = await permission.request();
    if (status.isGranted) return;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      status = await permission.status;
      if (!status.isGranted) throw StateError('Permission not granted: $permission');
      return;
    }

    while (status.isDenied) {
      status = await permission.request();
      if (status.isGranted) return;
    }
  }
}

