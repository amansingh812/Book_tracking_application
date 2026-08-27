import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidOk = await android?.requestNotificationsPermission() ?? true;
    final iosOk = await ios?.requestPermissions(alert: true, sound: true) ?? true;
    return androidOk && iosOk;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = 'Time to read',
    String body = 'Keep your reading streak alive!',
  }) async {
    await _plugin.zonedSchedule(
      _kReminderId,
      title,
      body,
      _nextInstanceOf(hour, minute),
      _notifDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(_kReminderId);
  }

  Future<void> showSessionComplete({required int minutes}) async {
    await _plugin.show(
      _kSessionId,
      'Session complete',
      '$minutes ${minutes == 1 ? 'minute' : 'minutes'} logged. Great reading!',
      _notifDetails(),
    );
  }

  static const _kReminderId = 1;
  static const _kSessionId = 2;

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails _notifDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'readora_reminders',
          'Reading reminders',
          channelDescription: 'Daily reading habit reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      );
}
