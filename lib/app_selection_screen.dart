import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class AppSelectionScreen extends StatefulWidget {
  final List<Application> installedApps;
  final List<Application> selectedApps;
  final Function(List<Application>) onAppsSelected;

  AppSelectionScreen({
    required this.installedApps,
    required this.selectedApps,
    required this.onAppsSelected,
  });

  @override
  _AppSelectionScreenState createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  late List<Application> _currentSelectedApps;

  @override
  void initState() {
    super.initState();
    _currentSelectedApps = List.from(widget.selectedApps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Apps'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onAppsSelected(_currentSelectedApps);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.installedApps.length,
        itemBuilder: (context, index) {
          final app = widget.installedApps[index];
          final isSelected = _currentSelectedApps.contains(app);

          return ListTile(
            title: Text(app.appName),
            trailing: isSelected ? Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _currentSelectedApps.remove(app);
                } else {
                  _currentSelectedApps.add(app);
                }
              });
            },
          );
        },
      ),
    );
  }
}
