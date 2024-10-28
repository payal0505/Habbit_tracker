import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'app_selection_screen.dart';
import 'app_usage_tracker.dart'; // Ensure this is imported

class SetAppPermissionsScreen extends StatefulWidget {
  final Function(List<Application>) onAppsSelected;
  final AppUsageTracker appUsageTracker;

  SetAppPermissionsScreen({
    required this.onAppsSelected,
    required this.appUsageTracker,
  });

  @override
  _SetAppPermissionsScreenState createState() => _SetAppPermissionsScreenState();
}

class _SetAppPermissionsScreenState extends State<SetAppPermissionsScreen> {
  List<Application> _installedApps = [];
  List<Application> _selectedApps = [];

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
  }

  Future<void> _fetchInstalledApps() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );
    setState(() {
      _installedApps = apps;
    });
  }

  void _navigateToAppSelectionScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppSelectionScreen(
          installedApps: _installedApps,
          selectedApps: _selectedApps,
          onAppsSelected: (selectedApps) {
            setState(() {
              _selectedApps = selectedApps;
            });

            // Add selected apps to AppUsageTracker
            for (var app in selectedApps) {
              widget.appUsageTracker.addSelectedApp('DND', app.appName, app.packageName); // Example for DND mode
            }

            widget.onAppsSelected(selectedApps);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Permissions for Apps'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _navigateToAppSelectionScreen,
            tooltip: 'Select Apps',
          ),
        ],
      ),
      body: _installedApps.isNotEmpty
          ? ListView.builder(
        itemCount: _installedApps.length,
        itemBuilder: (context, index) {
          final app = _installedApps[index];
          return ListTile(
            title: Text(app.appName),
            trailing: _selectedApps.contains(app) ? Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                if (_selectedApps.contains(app)) {
                  _selectedApps.remove(app);
                } else {
                  _selectedApps.add(app);
                }
              });
            },
          );
        },
      )
          : Center(child: CircularProgressIndicator()), // Consider adding a loading message
    );
  }
}
