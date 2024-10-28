import 'package:flutter/material.dart';

class BreakModeScreen extends StatelessWidget {
  final List<String> selectedApps;

  BreakModeScreen({required this.selectedApps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Break Mode'),
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
        child: Text('No apps selected for Break Mode'),
      ),
    );
  }
}
