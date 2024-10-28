import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_apps/device_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';


class PermissionsHelper {
  static Future<bool> requestUsageStatsPermission(BuildContext context) async {
    // Check if permission is already granted
    if (!await hasUsageStatsPermission()) {
      // Show a dialog or a message to the user
      bool? isDialogDismissed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Required'),
          content: Text('Please enable usage access in settings.'),
          actions: [
            TextButton(
              onPressed: () {
                // Open the settings page for your app
                _openUsageAccessSettings();
                Navigator.of(context).pop(true); // Close the dialog
              },
              child: Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Dismiss with false
              child: Text('Cancel'),
            ),
          ],
        ),
      );

      return isDialogDismissed ?? false; // Handle dialog result
    }
    return true; // Permission already granted
  }

  static Future<bool> hasUsageStatsPermission() async {
    // Implement a check for usage stats permission
    final hasPermission = await _checkUsageStatsPermission();
    return hasPermission;
  }

  static Future<bool> _checkUsageStatsPermission() async {
    // Use a platform channel to check if usage stats permission is granted
    const MethodChannel channel = MethodChannel('com.example.yourapp/usage_stats'); // Replace with your app's package name
    try {
      final bool? permissionGranted = await channel.invokeMethod('checkUsageStatsPermission');
      return permissionGranted ?? false;
    } catch (e) {
      return false; // Handle any exceptions, assume permission is not granted
    }
  }

  static Future<void> _openUsageAccessSettings() async {
    // Use Android Intent to open usage access settings
    final intent = AndroidIntent(
      action: 'android.settings.USAGE_ACCESS_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }
}
