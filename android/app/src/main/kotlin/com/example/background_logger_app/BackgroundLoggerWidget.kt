package com.example.background_logger_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews

class BackgroundLoggerWidget : AppWidgetProvider() {

    companion object {
        private const val ACTION_INCREMENT = "ACTION_INCREMENT"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val COUNTER_KEY = "flutter.app_counter"
        
        // Alternative keys to try based on Flutter's SharedPreferences patterns
        private val POSSIBLE_KEYS = arrayOf(
            "flutter.app_counter",
            "flutter.flutter.app_counter", 
            "app_counter",
            "flutter.counter",
            "counter"
        )
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        
        if (intent?.action == ACTION_INCREMENT && context != null) {
            // Increment counter in SharedPreferences
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            
            // Debug: Log all keys before increment
            val allKeysBefore = prefs.all.keys
            android.util.Log.d("BackgroundLoggerWidget", "Keys before increment: $allKeysBefore")
            
            // Find the correct key and increment
            var currentCount = 0
            var keyToUse = COUNTER_KEY // Default key
            
            for (key in POSSIBLE_KEYS) {
                if (prefs.contains(key)) {
                    currentCount = prefs.getInt(key, 0)
                    keyToUse = key
                    android.util.Log.d("BackgroundLoggerWidget", "Found existing counter at key '$key': $currentCount")
                    break
                }
            }
            
            val newCount = currentCount + 1
            android.util.Log.d("BackgroundLoggerWidget", "Incrementing from $currentCount to $newCount using key '$keyToUse'")
            
            prefs.edit().putInt(keyToUse, newCount).apply()
            
            // Debug: Log all keys after increment
            val allKeysAfter = prefs.all.keys
            android.util.Log.d("BackgroundLoggerWidget", "Keys after increment: $allKeysAfter")
            
            // Update all widgets
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, BackgroundLoggerWidget::class.java)
            val widgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            onUpdate(context, appWidgetManager, widgetIds)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // Get counter value from SharedPreferences
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        
        // Debug: Log all keys to see what's actually stored
        val allKeys = prefs.all.keys
        android.util.Log.d("BackgroundLoggerWidget", "All SharedPreferences keys: $allKeys")
        
        // Try to find the counter value using different possible keys
        var counter = 0
        var usedKey = ""
        for (key in POSSIBLE_KEYS) {
            if (prefs.contains(key)) {
                counter = prefs.getInt(key, 0)
                usedKey = key
                android.util.Log.d("BackgroundLoggerWidget", "Found counter at key '$key': $counter")
                break
            }
        }
        
        if (usedKey.isEmpty()) {
            android.util.Log.d("BackgroundLoggerWidget", "No counter key found, using default value 0")
        }

        val views = RemoteViews(context.packageName, R.layout.background_logger_widget)
        
        // Update counter text
        views.setTextViewText(R.id.widget_counter, counter.toString())

        // Set up click listener for increment button
        val incrementIntent = Intent(context, BackgroundLoggerWidget::class.java).apply {
            action = ACTION_INCREMENT
        }
        
        val incrementPendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId,
            incrementIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        views.setOnClickPendingIntent(R.id.widget_increment_button, incrementPendingIntent)

        // Set up click listener for the counter to open the app
        val openAppIntent = Intent(context, MainActivity::class.java)
        val openAppPendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        views.setOnClickPendingIntent(R.id.widget_counter, openAppPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
