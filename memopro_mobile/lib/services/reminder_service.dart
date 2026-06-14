import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/memo.dart';
import 'memo_service.dart';

class ReminderService {
  static final ReminderService instance = ReminderService._();
  ReminderService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Timer? _checkTimer;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    _startPeriodicCheck();
  }

  void _onNotificationTap(NotificationResponse response) {
    // 点击通知后，可以通过全局导航键跳转到对应备忘录
    debugPrint('Notification tapped: ${response.payload}');
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkReminders();
    });
  }

  void _checkReminders() {
    final pending = MemoService.instance.pendingReminders;
    for (final memo in pending) {
      _showReminderNotification(memo);
      MemoService.instance.updateMemo(memo.id, reminded: true);
    }
  }

  Future<void> _showReminderNotification(Memo memo) async {
    final androidDetails = AndroidNotificationDetails(
      'memopro_reminders',
      '备忘录提醒',
      channelDescription: 'MemoPro 备忘录时间提醒',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
      fullScreenIntent: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      memo.id.hashCode,
      '⏰ 备忘录提醒',
      memo.displayTitle,
      details,
      payload: memo.id,
    );
  }

  Future<void> scheduleReminder(Memo memo) async {
    if (!memo.hasReminder || memo.reminderTime == null) return;

    final scheduledDate = tz.TZDateTime.from(memo.reminderTime!, tz.local);

    // 如果时间已过，立即触发
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'memopro_scheduled',
      '定时提醒',
      channelDescription: 'MemoPro 定时备忘录提醒',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm'),
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      memo.id.hashCode,
      '⏰ 备忘录提醒',
      memo.displayTitle,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: memo.id,
    );
  }

  Future<void> cancelReminder(Memo memo) async {
    await _notifications.cancel(memo.id.hashCode);
  }

  void dispose() {
    _checkTimer?.cancel();
  }
}
