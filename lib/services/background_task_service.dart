import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BackgroundTaskService {
  static const String _backgroundLogTask = 'backgroundLogTask';
  static const String _isBackgroundTaskEnabledKey = 'isBackgroundTaskEnabled';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static Future<void> startBackgroundLogging() async {
    await Workmanager().registerPeriodicTask(
      _backgroundLogTask,
      _backgroundLogTask,
      frequency:
          const Duration(minutes: 15), // Minimum interval for periodic tasks
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isBackgroundTaskEnabledKey, true);
  }

  static Future<void> stopBackgroundLogging() async {
    await Workmanager().cancelByUniqueName(_backgroundLogTask);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isBackgroundTaskEnabledKey, false);
  }

  static Future<bool> isBackgroundLoggingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isBackgroundTaskEnabledKey) ?? false;
  }
}

// This callback runs in a separate isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'backgroundLogTask':
          await _handleBackgroundLogTask();
          break;
      }
      return Future.value(true);
    } catch (e) {
      // If there's an error, we still return true to prevent the task from retrying indefinitely
      return Future.value(true);
    }
  });
}

Future<void> _handleBackgroundLogTask() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now();

    // Create a log entry directly in SharedPreferences since we're in a separate isolate
    const String logsKey = 'app_logs';
    final logsJson = prefs.getString(logsKey);
    List<dynamic> logsList = [];

    if (logsJson != null) {
      logsList = jsonDecode(logsJson) as List;
    }

    // Create new log entry
    final logEntry = {
      'id': timestamp.millisecondsSinceEpoch.toString(),
      'message':
          'Background task executed successfully at ${timestamp.toString()}',
      'timestamp': timestamp.millisecondsSinceEpoch,
      'level': 'INFO',
      'source': 'BACKGROUND_TASK',
    };

    logsList.insert(0, logEntry);

    // Keep only the last 100 logs
    if (logsList.length > 100) {
      logsList.removeRange(100, logsList.length);
    }

    // Save back to SharedPreferences
    await prefs.setString(logsKey, jsonEncode(logsList));

    // Note: Notifications from background tasks have limitations on different platforms
    // and may not always work reliably
    // Background log task completed successfully
  } catch (e) {
    // Error in background task, but we continue silently
  }
}
