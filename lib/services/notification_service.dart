import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(settings);
    tz.initializeTimeZones();
    final location = tz.getLocation('Europe/Warsaw');
    tz.setLocalLocation(location);


    // Request permissions
    await Permission.notification.request();
    
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> showTestNotification() async {
  await _notifications.show(
    999,
    '🍽️ Test',
    'Immediate notification',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    int second = 0
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute, second);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print('Scheduled notification for $scheduledDate');
  }

  Future<void> cancelAll() async => await _notifications.cancelAll();

  Future<void> debugStatus() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final canSchedule = await androidPlugin.canScheduleExactNotifications();
      print('Can schedule exact: $canSchedule');
      
      final areEnabled = await androidPlugin.areNotificationsEnabled();
      print('Notifications enabled: $areEnabled');
    }
    
    final pending = await _notifications.pendingNotificationRequests();
    print('📋 Pending: ${pending.length}');
    for (var n in pending) {
      print('  ID: ${n.id}, Title: ${n.title}');
    }
  }
}