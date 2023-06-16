import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';

Future<void> configureLocalNotifications() async {
  // Define the initialization settings for your app
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('logo_pink');

  // Initialize the settings for both Android and iOS devices
  final InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);

  // Initialize the local notifications plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification);
}

Future<void> scheduleDailyReminder() async {
  // Define the notification details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'daily_reminder_channel_id',
    'Daily Reminder',
    channelDescription: 'Reminds users to watch their daily video',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Cancel any previously scheduled notifications
  await flutterLocalNotificationsPlugin.cancel(0);

  // Define the time for the daily reminder (12 PM)
  final now = tz.TZDateTime.now(tz.local);
  final scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    12,
    0,
  );

  // Schedule the daily reminder notification
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Daily Reminder',
    'Don\'t forget to watch your daily video!',
    scheduledDate,
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exact,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<void> onSelectNotification(payload) async {
  // Handle when the user taps on a notification
  if (payload != null) {
    debugPrint('Notification payload: $payload');
  }
}
