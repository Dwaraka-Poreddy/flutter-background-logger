import 'package:flutter/material.dart';
import 'services/background_task_service.dart';
import 'services/notification_service.dart';
import 'services/logger_service.dart';
import 'services/widget_service.dart';
import 'pages/logs_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await BackgroundTaskService.initialize();
  await NotificationService.getInstance();

  // Initialize widget service
  final widgetService = await WidgetService.getInstance();
  await widgetService.initializeWidget();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isBackgroundTaskEnabled = false;
  late LoggerService _loggerService;
  late NotificationService _notificationService;
  late WidgetService _widgetService;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _loggerService = await LoggerService.getInstance();
    _notificationService = await NotificationService.getInstance();
    _widgetService = await WidgetService.getInstance();

    // Load current counter value from SharedPreferences
    final currentCounter = await _widgetService.getCounterValue();
    setState(() {
      _counter = currentCounter;
    });

    // Check if background task is enabled
    final isEnabled = await BackgroundTaskService.isBackgroundLoggingEnabled();
    setState(() {
      _isBackgroundTaskEnabled = isEnabled;
    });

    // Log app startup
    await _loggerService.info('Application started');
  }

  Future<void> _incrementCounter() async {
    // Use widget service to increment counter (handles both app and widget updates)
    await _widgetService.incrementCounter(source: 'USER_ACTION');

    // Update local state
    final newCounter = await _widgetService.getCounterValue();
    setState(() {
      _counter = newCounter;
    });

    if (_counter % 5 == 0) {
      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Counter Milestone!',
        body: 'You have reached $_counter clicks!',
      );
      await _loggerService
          .info('Milestone notification sent for $_counter clicks');
    }
  }

  Future<void> _toggleBackgroundLogging() async {
    try {
      if (_isBackgroundTaskEnabled) {
        await BackgroundTaskService.stopBackgroundLogging();
        await _loggerService.info('Background logging stopped',
            source: 'USER_ACTION');
        setState(() {
          _isBackgroundTaskEnabled = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Background logging stopped')),
          );
        }
      } else {
        await BackgroundTaskService.startBackgroundLogging();
        await _loggerService.info('Background logging started',
            source: 'USER_ACTION');
        setState(() {
          _isBackgroundTaskEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Background logging started')),
          );
        }
      }
    } catch (e) {
      await _loggerService.error('Failed to toggle background logging: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _testNotification() async {
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Test Notification',
      body: 'This is a test notification from the app!',
    );
    await _loggerService.info('Test notification sent', source: 'USER_ACTION');
  }

  Future<void> _simulateError() async {
    await _loggerService.error('Simulated error for testing purposes',
        source: 'USER_ACTION');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulated error logged'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _simulateWarning() async {
    await _loggerService.warning('Simulated warning for testing purposes',
        source: 'USER_ACTION');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulated warning logged'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _addWidget() async {
    try {
      await _widgetService.requestPinWidget();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget pin request sent! Check your home screen.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      await _loggerService.error('Failed to add widget: $e',
          source: 'USER_ACTION');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding widget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateWidget() async {
    try {
      await _widgetService.updateWidget();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      await _loggerService.error('Failed to update widget: $e',
          source: 'USER_ACTION');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating widget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogsPage()),
              );
            },
            tooltip: 'View Logs',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Counter Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Counter Demo',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('You have pushed the button this many times:'),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _incrementCounter,
                      icon: const Icon(Icons.add),
                      label: const Text('Increment Counter'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Background Logging Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Background Logging',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isBackgroundTaskEnabled
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _isBackgroundTaskEnabled
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isBackgroundTaskEnabled
                              ? 'Background logging is ON'
                              : 'Background logging is OFF',
                          style: TextStyle(
                            color: _isBackgroundTaskEnabled
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _toggleBackgroundLogging,
                      icon: Icon(_isBackgroundTaskEnabled
                          ? Icons.stop
                          : Icons.play_arrow),
                      label: Text(_isBackgroundTaskEnabled
                          ? 'Stop Logging'
                          : 'Start Logging'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isBackgroundTaskEnabled
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Home Screen Widget Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Home Screen Widget',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add a widget to your home screen to view and increment the counter directly from your home screen!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _addWidget,
                          icon: const Icon(Icons.add_to_home_screen),
                          label: const Text('Add Widget'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _updateWidget,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Update Widget'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Testing Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Testing Tools',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testNotification,
                          icon: const Icon(Icons.notifications),
                          label: const Text('Test Notification'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _simulateError,
                          icon: const Icon(Icons.error),
                          label: const Text('Log Error'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _simulateWarning,
                          icon: const Icon(Icons.warning),
                          label: const Text('Log Warning'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // View Logs Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LogsPage()),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('View All Logs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
