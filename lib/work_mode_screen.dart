import 'package:flutter/material.dart';

class WorkModeScreen extends StatelessWidget {
  final List<String> selectedApps;

  WorkModeScreen({required this.selectedApps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Mode'),
      ),
      body: selectedApps.isNotEmpty
          ? ListView.builder(
        itemCount: selectedApps.length,
        itemBuilder: (context, index) {
          String packageName = selectedApps[index];
          return ListTile(
            title: Text(packageName),
          );
        },
      )
          : Center(
        child: Text('No apps selected for Work Mode'),
      ),
    );
  }
}
