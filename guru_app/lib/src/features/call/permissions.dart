import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class CallPermissions {
  static Future<void> ensure() async {
    if (Platform.isIOS) {
      // iOS prompts are handled when accessing the devices; we still request to
      // keep the flow explicit and consistent.
      await Permission.camera.request();
      await Permission.microphone.request();
      return;
    }

    await _requestUntilGranted(Permission.camera);
    await _requestUntilGranted(Permission.microphone);

    // Android 12+ Bluetooth permission for routing to BT devices.
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
      if (!status.isGranted) {
        throw StateError('Permission not granted: $permission');
      }
      return;
    }

    // Denied (not permanent) – ask again (user request requirement).
    while (status.isDenied) {
      status = await permission.request();
      if (status.isGranted) return;
    }
  }
}

