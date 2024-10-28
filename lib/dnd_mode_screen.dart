import 'package:flutter/material.dart';

class DndModeScreen extends StatelessWidget {
  final List<String> selectedApps;

  DndModeScreen({required this.selectedApps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DND Mode'),
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
        child: Text('No apps selected for DND Mode'),
      ),
    );
  }
}
