class AppUsageTracker {
  Map<String, DateTime> startTimes = {};
  Map<String, Duration> totalTimeSpent = {
    'DND': Duration(),
    'Work': Duration(),
    'Break': Duration(),
  };

  // To track selected apps for each mode
  final Map<String, Map<String, String>> selectedApps = {}; // mode -> {packageName -> appName}

  // Start tracking time for a specific mode
  void startTracking(String mode) {
    startTimes[mode] = DateTime.now();
  }

  // Stop tracking time for a specific mode and update the total time spent
  void stopTracking(String mode) {
    if (startTimes.containsKey(mode)) {
      Duration timeSpent = DateTime.now().difference(startTimes[mode]!);
      totalTimeSpent[mode] = totalTimeSpent[mode]! + timeSpent;
      startTimes.remove(mode);
    } else {
      // Optional: Handle cases where tracking was not started
      print('Error: No tracking started for mode $mode');
    }
  }

  // Add a selected app for a specific mode
  void addSelectedApp(String mode, String appName, String packageName) {
    if (!selectedApps.containsKey(mode)) {
      selectedApps[mode] = {}; // Initialize mode if not present
    }
    selectedApps[mode]![packageName] = appName; // Store app details
  }

  // Get total time spent for each mode
  Map<String, Duration> getTotalTimeSpent() {
    return totalTimeSpent;
  }

  // Reset total time spent for a new day/session
  void resetTotalTime() {
    totalTimeSpent = {
      'DND': Duration(),
      'Work': Duration(),
      'Break': Duration(),
    };
  }

  // Get selected apps for a specific mode
  Map<String, String>? getSelectedApps(String mode) {
    return selectedApps[mode];
  }
}
