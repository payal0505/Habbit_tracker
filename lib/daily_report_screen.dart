import 'package:flutter/material.dart';
import 'package:usage_stats_new/usage_stats.dart';
import 'app_usage_tracker.dart';
import 'time_graph.dart'; // Import your new TimeGraph class

class DailyReportScreen extends StatelessWidget {
  final AppUsageTracker appUsageTracker;

  // Use named parameters to make it clearer
  DailyReportScreen({required this.appUsageTracker});

  @override
  Widget build(BuildContext context) {
    Map<String, Duration> data = appUsageTracker.getTotalTimeSpent();

    return Scaffold(
      appBar: AppBar(title: Text('Daily Report')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: data.keys.length,
              itemBuilder: (context, index) {
                String mode = data.keys.elementAt(index);
                Duration duration = data[mode]!;
                return ListTile(
                  title: Text(mode),
                  subtitle: Text('${duration.inMinutes} minutes'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (data.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Container(
                      width: 300,
                      height: 300,
                      child: TimeGraph(data),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text('No data available for the selected apps.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text('View Graph'),
          ),
        ],
      ),
    );
  }
}
