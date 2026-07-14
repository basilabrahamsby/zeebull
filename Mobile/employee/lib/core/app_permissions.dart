import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Central permission manager.
/// Call [AppPermissions.requestAll] once at app startup (e.g. inside SplashScreen or AuthWrapper).
class AppPermissions {
  AppPermissions._();

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Requests all permissions the app needs.
  /// Silently skips permissions that are already granted.
  /// Returns `true` if all critical permissions (location + camera) are granted.
  static Future<bool> requestAll(BuildContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    // 1. Core permissions requested together (marshmallow-style bulk request)
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.photos,        // READ_MEDIA_IMAGES on Android 13+
      Permission.storage,       // READ/WRITE_EXTERNAL_STORAGE on older Android
      Permission.notification,  // POST_NOTIFICATIONS on Android 13+
    ].request();

    debugPrint('[PERMISSIONS] Results: $statuses');

    // 2. Location is critical — show a rationale dialog if denied
    final locationStatus = statuses[Permission.location] ?? PermissionStatus.denied;
    if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          title: 'Location Required',
          message:
              'This app tracks your location while you are on duty to log your movement. '
              'Please grant Location permission to continue.',
          permission: Permission.location,
          isPermanent: locationStatus.isPermanentlyDenied,
        );
      }
    }

    // 3. Background location (Android only, must be asked AFTER foreground location is granted)
    if (Platform.isAndroid) {
      final fgGranted = await Permission.location.isGranted;
      if (fgGranted) {
        final bgStatus = await Permission.locationAlways.status;
        if (!bgStatus.isGranted) {
          final result = await Permission.locationAlways.request();
          debugPrint('[PERMISSIONS] Background location: $result');
        }
      }
    }

    // 4. Camera rationale if denied
    final cameraStatus = statuses[Permission.camera] ?? PermissionStatus.denied;
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          title: 'Camera Required',
          message:
              'Camera is used to capture your selfie when clocking in and out. '
              'Please grant Camera permission.',
          permission: Permission.camera,
          isPermanent: cameraStatus.isPermanentlyDenied,
        );
      }
    }

    final allCriticalGranted =
        (await Permission.location.isGranted) && (await Permission.camera.isGranted);

    return allCriticalGranted;
  }

  // ─── Quick checks (use wherever needed) ─────────────────────────────────

  static Future<bool> hasLocation() async => Permission.location.isGranted;
  static Future<bool> hasCamera() async => Permission.camera.isGranted;
  static Future<bool> hasStorage() async =>
      Platform.isAndroid ? (await Permission.photos.isGranted || await Permission.storage.isGranted) : true;

  // ─── Private helpers ─────────────────────────────────────────────────────

  static Future<void> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Permission permission,
    required bool isPermanent,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_open_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (isPermanent) {
                // Open app settings so user can manually toggle
                await openAppSettings();
              } else {
                await permission.request();
              }
            },
            child: Text(isPermanent ? 'Open Settings' : 'Allow'),
          ),
        ],
      ),
    );
  }
}
