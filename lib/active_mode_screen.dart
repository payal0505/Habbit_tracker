import 'package:flutter/material.dart';
import 'dart:async';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_project_final/permissions_helper.dart';

class ActiveModeScreen extends StatelessWidget {
  final List<Application> selectedApps;

  ActiveModeScreen({required this.selectedApps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Active Mode'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeButton(context, 'DND'),
              SizedBox(height: 20),
              _buildModeButton(context, 'Work'),
              SizedBox(height: 20),
              _buildModeButton(context, 'Break'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String mode) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the App Selection Screen with the selected mode
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppSelectionScreen(selectedMode: mode),
          ),
        );
      },
      child: Text(mode),
    );
  }
}

class AppSelectionScreen extends StatefulWidget {
  final String selectedMode;

  AppSelectionScreen({required this.selectedMode});

  @override
  _AppSelectionScreenState createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  List<Application> _installedApps = [];
  final TextEditingController _timeController = TextEditingController();

  // Separate maps to store selected apps and time for each mode
  final Map<Application, Duration> _selectedAppsDND = {};
  final Map<Application, Duration> _selectedAppsWork = {};
  final Map<Application, Duration> _selectedAppsBreak = {};

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
  }

  void _fetchInstalledApps() async {
    if (await PermissionsHelper.requestUsageStatsPermission(context)) {
      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );
      setState(() {
        _installedApps = apps;
      });
    } else {
      // Handle the case when permission is not granted
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
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

  Future<void> _inputTimeForApp(Application app) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Time for ${app.appName}'),
          content: TextField(
            controller: _timeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Time in minutes',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                int minutes = int.tryParse(_timeController.text) ?? 0;
                if (minutes > 0) {
                  setState(() {
                    // Add app and time to the relevant mode map
                    if (widget.selectedMode == 'DND') {
                      _selectedAppsDND[app] = Duration(minutes: minutes);
                    } else if (widget.selectedMode == 'Work') {
                      _selectedAppsWork[app] = Duration(minutes: minutes);
                    } else if (widget.selectedMode == 'Break') {
                      _selectedAppsBreak[app] = Duration(minutes: minutes);
                    }
                  });
                  Navigator.of(context).pop();
                  _timeController.clear();
                } else {
                  _showInvalidTimeDialog();
                }
              },
              child: Text('Set Time'),
            ),
          ],
        );
      },
    );
  }

  void _showInvalidTimeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Invalid Input'),
        content: Text('Please enter a positive time value.'),
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

  void _startTimersForMode(String mode) {
    Map<Application, Duration> selectedApps = _getSelectedAppsForCurrentMode();

    selectedApps.forEach((app, duration) {
      Timer(duration, () {
        _showNotification(app.appName);
      });
    });
  }

  void _showNotification(String appName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Time\'s up!'),
        content: Text('Time for $appName has ended!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Apps for ${widget.selectedMode} Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _installedApps.isNotEmpty
                  ? ListView.builder(
                itemCount: _installedApps.length,
                itemBuilder: (context, index) {
                  Application app = _installedApps[index];
                  // Show selected time for apps depending on the mode
                  String? displayTime = _getAppDisplayTime(app);

                  return ListTile(
                    title: Text(app.appName),
                    trailing: displayTime != null ? Text(displayTime) : null,
                    onTap: () {
                      _inputTimeForApp(app);
                    },
                  );
                },
              )
                  : Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_getSelectedAppsForCurrentMode().isNotEmpty) {
                  _startTimersForMode(widget.selectedMode);
                }
              },
              child: Text('Start ${widget.selectedMode} Mode'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 30.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get selected apps for the current mode
  Map<Application, Duration> _getSelectedAppsForCurrentMode() {
    if (widget.selectedMode == 'DND') {
      return _selectedAppsDND;
    } else if (widget.selectedMode == 'Work') {
      return _selectedAppsWork;
    } else {
      return _selectedAppsBreak;
    }
  }

  // Helper function to get display time for the current mode
  String? _getAppDisplayTime(Application app) {
    if (widget.selectedMode == 'DND' && _selectedAppsDND.containsKey(app)) {
      return '${_selectedAppsDND[app]?.inMinutes ?? 0} min';
    } else if (widget.selectedMode == 'Work' && _selectedAppsWork.containsKey(app)) {
      return '${_selectedAppsWork[app]?.inMinutes ?? 0} min';
    } else if (widget.selectedMode == 'Break' && _selectedAppsBreak.containsKey(app)) {
      return '${_selectedAppsBreak[app]?.inMinutes ?? 0} min';
    }
    return null;
  }
}
