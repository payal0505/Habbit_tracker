import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class UpdateTimeScreen extends StatefulWidget {
  final Map<Application, Duration> selectedAppsWithTime;

  UpdateTimeScreen({required this.selectedAppsWithTime});

  @override
  _UpdateTimeScreenState createState() => _UpdateTimeScreenState();
}

class _UpdateTimeScreenState extends State<UpdateTimeScreen> {
  TextEditingController _timeController = TextEditingController();

  // Function to update time for a specific app
  void _updateTimeForApp(Application app) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Time for ${app.appName}'),
          content: TextField(
            controller: _timeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'New time in minutes',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                int minutes = int.tryParse(_timeController.text) ?? 0;
                setState(() {
                  widget.selectedAppsWithTime[app] = Duration(minutes: minutes);
                });
                Navigator.of(context).pop();
                _timeController.clear();
              },
              child: Text('Update Time'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Time'),
      ),
      body: widget.selectedAppsWithTime.isNotEmpty
          ? ListView.builder(
        itemCount: widget.selectedAppsWithTime.length,
        itemBuilder: (context, index) {
          Application app = widget.selectedAppsWithTime.keys.elementAt(index);
          return ListTile(
            title: Text(app.appName),
            trailing: Text('${widget.selectedAppsWithTime[app]!.inMinutes} min'),
            onTap: () {
              _updateTimeForApp(app);
            },
          );
        },
      )
          : Center(child: Text("No apps selected")),
    );
  }
}
