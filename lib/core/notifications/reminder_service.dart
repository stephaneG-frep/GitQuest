import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

abstract interface class ReminderScheduler {
  Future<bool> requestPermission();
  Future<void> scheduleDaily({required int hour, required int minute});
  Future<void> cancel();
}

class LocalReminderService implements ReminderScheduler {
  LocalReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notificationId = 7001;
  static const _channelId = 'gitquest_daily_learning';
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    timezone_data.initializeTimeZones();
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(
        timezone.getLocation(deviceTimezone.identifier),
      );
    } on Object {
      timezone.setLocalLocation(timezone.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Ouvrir GitQuest',
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await initialize();
    if (kIsWeb ||
        !<TargetPlatform>{
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        }.contains(defaultTargetPlatform)) {
      return;
    }
    await _plugin.cancel(id: _notificationId);
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'Une petite quête Git ?',
      body: 'Quelques minutes suffisent pour entretenir tes réflexes.',
      scheduledDate: _nextReminder(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Rappel d’apprentissage',
          channelDescription: 'Rappel quotidien facultatif de GitQuest',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily-learning',
    );
  }

  timezone.TZDateTime _nextReminder(int hour, int minute) {
    final now = timezone.TZDateTime.now(timezone.local);
    var scheduled = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  @override
  Future<void> cancel() async {
    await initialize();
    await _plugin.cancel(id: _notificationId);
  }
}
