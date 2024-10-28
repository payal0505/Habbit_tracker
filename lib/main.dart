import 'package:flutter/material.dart';
import 'active_mode_screen.dart';
import 'update_time_screen.dart';
import 'set_app_permissions_screen.dart';
import 'daily_report_screen.dart';
import 'package:device_apps/device_apps.dart';
import 'permissions_helper.dart';
import 'package:usage_stats_new/usage_stats.dart';
import 'app_usage_tracker.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _appCheckTimer;
  Map<Application, Duration> selectedAppsWithTime = {};
  List<Application> selectedApps = [];
  AppUsageTracker appUsageTracker = AppUsageTracker();
  List<UsageInfo> usageStats = []; // Variable for storing usage stats

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startMonitoringApps();
  }

  void _startAppCheckTimer() {
    _appCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkActiveApp();
    });
  }

  @override
  void dispose() {
    _appCheckTimer?.cancel();
    super.dispose();
  }

  void _checkActiveApp() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

    // Ensure you check for permission before fetching usage stats
    bool isPermissionGranted = (await UsageStats.checkUsagePermission()) ?? false; // Handle null
    if (isPermissionGranted) {
      final List<UsageInfo> usageInfo = await UsageStats.queryUsageStats(startDate, endDate);

      if (usageInfo.isNotEmpty) {
        String? currentApp = usageInfo[0].packageName;

        // Check if the current app is in the selected apps list
        if (appUsageTracker.selectedApps.containsKey(currentApp)) {
          appUsageTracker.startTracking(currentApp!); // Track the current app
        }
      }
    } else {
      print('Usage permission not granted');
    }
  }

  void _startMonitoringApps() async {
    await getUsage(); // Fetch usage stats when starting monitoring
    _startAppCheckTimer();
  }

  Future<void> getUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);

    // Grant usage permission
    await UsageStats.grantUsagePermission();

    // Check if permission is granted
    bool isPermissionGranted = (await UsageStats.checkUsagePermission()) ?? false; // Handle null
    if (isPermissionGranted) {
      // Query usage stats
      List<UsageInfo> stats = await UsageStats.queryUsageStats(startDate, endDate);
      setState(() {
        usageStats = stats; // Update state with fetched stats
      });
    } else {
      // Handle permission not granted scenario
      print('Usage permission not granted');
    }
  }

  Future<void> _requestPermissions() async {
    bool granted = await PermissionsHelper.requestUsageStatsPermission(context);
    if (!granted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Permission Required'),
          content: Text('Please enable usage access in settings.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus Timer'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (selectedApps.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveModeScreen(selectedApps: selectedApps),
                      ),
                    );
                  } else {
                    _showAlertDialog('No Apps Selected', 'Please select apps in Set App Permissions.');
                  }
                },
                child: Text('Start Active Mode'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (selectedAppsWithTime.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateTimeScreen(selectedAppsWithTime: selectedAppsWithTime),
                      ),
                    );
                  }
                },
                child: Text('Update Time'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetAppPermissionsScreen(
                        onAppsSelected: (newSelectedApps) {
                          setState(() {
                            selectedApps = newSelectedApps;
                          });
                        },
                        appUsageTracker: appUsageTracker, // Pass the existing instance
                      ),
                    ),
                  );
                },
                child: Text('Set App Permissions'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyReportScreen(appUsageTracker: appUsageTracker),
                    ),
                  );
                },
                child: Text('View Daily Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
