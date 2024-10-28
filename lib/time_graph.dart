import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TimeGraph extends StatelessWidget {
  final Map<String, Duration> timeData;

  TimeGraph(this.timeData);

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = timeData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value.inMinutes.toDouble(),
            color: Colors.blue,
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Customize how you want the bottom titles to appear
                return Text(timeData.keys.elementAt(value.toInt()));
              },
            ),
          ),
        ),
      ),
    );
  }
}
