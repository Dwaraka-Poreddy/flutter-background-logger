# Background Logger App

A comprehensive Flutter application demonstrating centralized logging, background task scheduling, and local notifications using `shared_preferences`, `workmanager`, and `flutter_local_notifications`.

## Features

### 🚀 Main Features

1. **Centralized Logging System**
   - Persistent logging using SharedPreferences
   - Multiple log levels (INFO, WARNING, ERROR, DEBUG)
   - Source tracking for log entries
   - Automatic timestamp recording

2. **Background Task Scheduling**
   - Periodic background logging every 15 minutes
   - Logs continue even when app is closed/backgrounded
   - Start/stop background logging functionality

3. **Logs Management Page**
   - View all logged entries with filtering options
   - Filter by log level (ALL, INFO, WARNING, ERROR, DEBUG)
   - Clear all logs functionality
   - Pull-to-refresh support
   - Color-coded log levels with icons

4. **Local Notifications**
   - Test notifications on demand
   - Milestone notifications (every 5 counter increments)
   - Background task notifications (platform limitations apply)

5. **Interactive Demo Features**
   - Counter with logging integration
   - Manual error/warning generation for testing
   - Real-time background task status display

6. **Home Screen Widget (Android)**
   - Display current button click count on home screen
   - Increment counter directly from widget
   - Synchronized with app data using SharedPreferences
   - Beautiful gradient design with rounded corners

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode for mobile development
- Device or emulator for testing

### Installation

1. Clone the repository or create the project structure
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## App Structure

```
lib/
├── main.dart                           # Main app entry point
├── services/
│   ├── logger_service.dart             # Centralized logging service
│   ├── notification_service.dart       # Local notifications service
│   └── background_task_service.dart    # Background task management
└── pages/
    └── logs_page.dart                  # Logs viewing and management page
```

## Usage Guide

### Main Page Features

1. **Counter Demo**
   - Tap "Increment Counter" to increase the counter
   - Each increment is logged automatically
   - Every 5th increment triggers a milestone notification

2. **Background Logging Control**
   - Toggle "Start/Stop Logging" to enable/disable background tasks
   - When enabled, the app logs a message every 15 minutes
   - Status indicator shows current background logging state

3. **Testing Tools**
   - "Test Notification" - Sends a sample notification
   - "Log Error" - Creates a sample error log entry
   - "Log Warning" - Creates a sample warning log entry

4. **View Logs**
   - Access the logs page from the app bar icon or bottom button
   - See all logged activities in chronological order

5. **Home Screen Widget (Android)**
   - Tap "Add Widget" for instructions on manually adding the widget
   - Long-press home screen → Widgets → Background Logger App
   - Widget shows current counter and has increment button
   - Data automatically syncs between app and widget via SharedPreferences

### Logs Page Features

1. **Filtering**
   - Use the dropdown to filter logs by level
   - Options: ALL, INFO, WARNING, ERROR, DEBUG

2. **Log Management**
   - Tap refresh icon to reload logs
   - Tap delete icon to clear all logs (with confirmation)
   - Pull down to refresh the list

3. **Log Information**
   - Each log entry shows message, source, timestamp, and level
   - Color-coded icons for easy identification
   - Expandable view for long messages

## Technical Implementation

### Shared Preferences Usage

The app demonstrates several key `shared_preferences` patterns:

1. **LoggerService** - Stores log entries as JSON strings
2. **BackgroundTaskService** - Persists background task state
3. **Automatic serialization/deserialization** of complex data structures

### Key Shared Preferences Operations

```dart
// Storing complex data
final logsJson = jsonEncode(logs.map((log) => log.toJson()).toList());
await prefs.setString(_logsKey, logsJson);

// Retrieving and parsing data
final logsJson = prefs.getString(_logsKey);
final logsList = jsonDecode(logsJson) as List;
final logs = logsList.map((json) => LogEntry.fromJson(json)).toList();

// Simple boolean storage
await prefs.setBool(_isBackgroundTaskEnabledKey, true);
final isEnabled = prefs.getBool(_isBackgroundTaskEnabledKey) ?? false;
```

### Background Tasks

The app uses `workmanager` for background execution:

- **Periodic Tasks**: Scheduled every 15 minutes (minimum allowed interval)
- **Persistence**: Task state survives app restarts
- **Isolation**: Background code runs in separate isolate
- **Limitations**: Platform-specific restrictions on background execution

### Notifications

Local notifications are implemented with proper platform configuration:

- **Android**: Uses notification channels with proper permissions
- **iOS**: Requests permissions for alerts, badges, and sounds
- **Cross-platform**: Unified API for consistent behavior

## Platform-Specific Notes

### Android
- Background tasks work reliably
- Notifications require user permission on Android 13+
- Doze mode and battery optimization may affect background execution

### iOS
- Background execution is more restricted
- Background App Refresh must be enabled for background tasks
- Silent notifications have limitations

## Testing the App

1. **Basic Logging**
   - Increment the counter and check logs page
   - Use error/warning buttons to generate different log levels

2. **Background Tasks**
   - Enable background logging
   - Put the app in background for 15+ minutes
   - Return to app and check logs for background entries

3. **Notifications**
   - Test immediate notifications with the test button
   - Trigger milestone notifications by reaching counter multiples of 5

4. **Data Persistence**
   - Generate logs and close the app completely
   - Restart the app and verify logs are preserved

5. **Home Screen Widget (Android)**
   - Tap "Add Widget" in the app to request widget placement
   - Long-press on home screen → Widgets → Background Logger App
   - Add the widget to your home screen
   - Test incrementing from widget and verify sync with app

## Troubleshooting

### Background Tasks Not Working
- Check if battery optimization is disabled for the app
- Ensure the app has background execution permissions
- Verify that background app refresh is enabled (iOS)

### Notifications Not Appearing
- Check notification permissions in device settings
- Ensure the app is not in Do Not Disturb mode
- Verify notification channels are properly configured

### Logs Not Persisting
- Check device storage space
- Verify SharedPreferences write permissions
- Ensure the app completed initialization properly

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.5.3
  workmanager: ^0.7.0
  flutter_local_notifications: ^19.3.0
  cupertino_icons: ^1.0.8
```

## Contributing

This is a sample app demonstrating Flutter development patterns. Feel free to extend it with additional features such as:

- Export logs to file
- Remote logging capabilities
- Custom notification sounds
- Log search functionality
- Analytics and usage tracking

## License

This project is for educational purposes and demonstrates Flutter development best practices.
# flutter-background-logger
