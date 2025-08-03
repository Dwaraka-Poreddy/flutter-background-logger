import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class WidgetService {
  static const String _appCounterKey = 'flutter.app_counter';

  // Alternative key patterns to try
  static const List<String> _possibleKeys = [
    'flutter.app_counter',
    'app_counter',
    'flutter.counter',
    'counter'
  ];

  static WidgetService? _instance;
  late SharedPreferences _prefs;
  late LoggerService _loggerService;

  WidgetService._internal();

  static Future<WidgetService> getInstance() async {
    if (_instance == null) {
      _instance = WidgetService._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loggerService = await LoggerService.getInstance();
  }

  // Get current counter value from SharedPreferences
  Future<int> getCounterValue() async {
    // Try different key patterns
    for (String key in _possibleKeys) {
      if (_prefs.containsKey(key)) {
        final value = _prefs.getInt(key) ?? 0;
        await _loggerService.debug('Found counter value for key "$key": $value',
            source: 'WIDGET_SERVICE');
        return value;
      }
    }

    await _loggerService.debug(
        'No counter key found, returning default value 0',
        source: 'WIDGET_SERVICE');
    return 0;
  }

  // Increment counter and update both app and widget
  Future<void> incrementCounter({String source = 'APP'}) async {
    final currentCount = await getCounterValue();
    final newCount = currentCount + 1;

    // Save to SharedPreferences using the primary key
    await _prefs.setInt(_appCounterKey, newCount);

    await _loggerService.debug(
        'Setting counter key "$_appCounterKey" to value: $newCount',
        source: 'WIDGET_SERVICE');

    // Log the action
    await _loggerService.info('Counter incremented to $newCount via $source',
        source: source);

    // Update widget
    await updateWidget();
  }

  // Update the home screen widget (handled automatically via SharedPreferences)
  Future<void> updateWidget() async {
    final counterValue = await getCounterValue();
    await _loggerService.debug(
        'Widget data synced automatically via SharedPreferences. Counter: $counterValue',
        source: 'WIDGET_SERVICE');
  }

  // Handle widget button clicks
  static Future<void> handleWidgetClick(String action) async {
    try {
      final widgetService = await WidgetService.getInstance();

      switch (action) {
        case 'increment':
          await widgetService.incrementCounter(source: 'WIDGET');
          break;
        default:
          final loggerService = await LoggerService.getInstance();
          await loggerService.warning('Unknown widget action: $action',
              source: 'WIDGET');
      }
    } catch (e) {
      final loggerService = await LoggerService.getInstance();
      await loggerService.error('Error handling widget click: $e',
          source: 'WIDGET');
    }
  }

  // Initialize widget with current data
  Future<void> initializeWidget() async {
    await updateWidget();
    await _loggerService.info('Home screen widget initialized',
        source: 'WIDGET_SERVICE');
  }

  // Get widget configuration status
  Future<bool> isWidgetConfigured() async {
    return true; // Widget is available for manual addition
  }

  // Request to pin widget to home screen
  Future<void> requestPinWidget() async {
    await _loggerService.info(
        'To add widget: Long-press home screen → Widgets → Background Logger App',
        source: 'WIDGET_SERVICE');
  }
}
